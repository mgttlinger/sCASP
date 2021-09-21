:- module(scasp_dyncall,
          [ scasp/1,                    % :Query
            scasp_query_clauses/2,      % :Query, -Clauses
            op(900, fy, not)
          ]).
:- use_module(compile).
:- use_module(embed).
:- use_module(common).
:- use_module(modules).
:- use_module(io).

:- meta_predicate
    scasp(0),
    scasp_query_clauses(:, -).

/** <module>

This predicate assembles the clauses  that   are  reachable from a given
goal.

Issues:

  - Represent classical negation as -Term?  Alternatives:
    - Just use -Term.  Disadvantage is program analysis and module
      dependencies.
    - Provide goal- and term-expansion to intern the - into the functor
      name.   Disadvantage is that we need scasp_assert/1, etc.
*/

scasp(Query) :-
    scasp_query_clauses(Query, Clauses),
    qualify(Query, _:QQuery),
    in_temporary_module(
        Module,
        prepare(Clauses, Module, []),
        scasp_embed:scasp_call(Module:QQuery)).

prepare(Clauses, Module, Options) :-
    scasp_compile(Module:Clauses, Options),
    (   debugging(scasp(code))
    ->  scasp_portray_program(Module:[])
    ;   true
    ).

qualify(M:Q0, M:Q) :-
    qualify(Q0, M, Q1),
    intern_negation(Q1, Q).

%!  scasp_query_clauses(:Query, -Clauses) is det.

:- det(scasp_query_clauses/2).

scasp_query_clauses(Query, Clauses) :-
    query_callees(Query, Callees0),
    include_global_constraint(Callees0, Constraints, Callees),
    findall(Clause, scasp_clause(Callees, Clause), Clauses, QConstraints),
    maplist(mkconstraint, Constraints, QConstraints).

scasp_clause(Callees, Clause) :-
    member(PI, Callees),
    pi_head(PI, M:Head),
    @(clause(Head, Body), M),
    mkclause(Head, Body, M, Clause).

mkclause(Head, true, M, Clause) =>
    qualify(Head, M, Clause).
mkclause(Head, Body, M, Clause) =>
    qualify((Head:-Body), M, Clause).

mkconstraint(M:Body, (:- Constraint)) :-
    qualify(Body, M, Constraint).

qualify(-(Head), M, Q) =>
    Q = -QHead,
    qualify(Head, M, QHead).
qualify(not(Head), M, Q) =>
    Q = not(QHead),
    qualify(Head, M, QHead).
qualify((A,B), M, Q) =>
    Q = (QA,QB),
    qualify(A, M, QA),
    qualify(B, M, QB).
qualify((A:-B), M, Q) =>
    Q = (QA:-QB),
    qualify(A, M, QA),
    qualify(B, M, QB).
qualify(G, M, Q), callable(G) =>
    encoded_module_term(M:G, Q).

%!  query_callees(:Query, -Callees) is det.
%
%   True when Callees is a list   of predicate indicators for predicates
%   reachable from Query.
%
%   @arg Callees is an ordered set.

query_callees(M:Query, Callees) :-
    findall(Call, body_calls_pi(Query,M,Call), Calls0),
    sort(Calls0, Calls),
    callee_graph(Calls, Callees).

body_calls_pi(Query, M, PI) :-
    body_calls(Query, M, Call),
    pi_head(PI, Call).

callee_graph(Preds, Nodes) :-
    empty_assoc(Expanded),
    callee_closure(Preds, Expanded, Preds, Nodes0),
    sort(Nodes0, Nodes).

callee_closure([], _, Preds, Preds).
callee_closure([H|T], Expanded, Preds0, Preds) :-
    (   get_assoc(H, Expanded, _)
    ->  callee_closure(T, Expanded, Preds0, Preds)
    ;   put_assoc(H, Expanded, true, Expanded1),
        pi_head(H, Head),
        predicate_callees(Head, Called),
        exclude(expanded(Expanded1), Called, New),
        append(New, T, Agenda),
        append(New, Preds0, Preds1),
        callee_closure(Agenda, Expanded1, Preds1, Preds)
    ).

expanded(Assoc, PI) :-
    get_assoc(PI, Assoc, _).

%!  include_global_constraint(+Callees, -Constraints, -AllCallees)

include_global_constraint(Callees0, [Body|T], Callees) :-
    global_constraint(Body),
    query_callees(Body, Called),
    ord_intersect(Callees0, Called),
    ord_union(Callees0, Called, Callees1),
    Callees1 \== Callees0,
    !,
    include_global_constraint(Callees1, T, Callees).
include_global_constraint(Callees, [], Callees).


global_constraint(M:Body) :-
    current_module(M),
    current_predicate(M:(-)/0),
    \+ predicate_property(M:(-), imported_from(_)),
    @(clause(-, Body), M).

%!  predicate_callees(:Head, -Callees) is det.
%
%   True when Callees is the list of _direct_ callees from Head.  Each
%   callee is a _predicate indicator_.

:- dynamic predicate_callees_c/4.

predicate_callees(M:Head, Callees) :-
    predicate_callees_c(Head, M, Gen, Callees0),
    predicate_generation(M:Head, Gen),
    !,
    Callees = Callees0.
predicate_callees(M:Head, Callees) :-
    retractall(predicate_callees_c(Head, M, _, _)),
    predicate_callees_nc(M:Head, Callees0),
    predicate_generation(M:Head, Gen),
    assertz(predicate_callees_c(Head, M, Gen, Callees0)),
    Callees = Callees0.

predicate_callees_nc(Head, Callees) :-
    findall(Callee, predicate_calls(Head, Callee), Callees0),
    sort(Callees0, Callees).

predicate_calls(Head0, PI) :-
    generalise(Head0, M:Head),
    @(clause(Head, Body), M),
    body_calls(Body, M, Callee),
    pi_head(PI, Callee).

body_calls(true, _M, _) => fail.
body_calls((A,B), M, Callee) =>
    (   body_calls(A, M, Callee)
    ;   body_calls(B, M, Callee)
    ).
body_calls(not(A), M, Callee) =>
    body_calls(A, M, Callee).
body_calls(N, M, Callee), rm_classic_negation(N,A) =>
    body_calls(A, M, Callee).
body_calls(M:A, _, Callee), atom(M) =>
    body_calls(A, M, Callee).
body_calls(G, M, CalleePM), callable(G) =>
    implementation(M:G, Callee0),
    generalise(Callee0, Callee),
    (   predicate_property(Callee, interpreted),
        \+ predicate_property(Callee, meta_predicate(_))
    ->  pm(Callee, CalleePM)
    ;   \+ predicate_property(Callee, _)
    ->  pm(Callee, CalleePM)
    ;   pi_head(CalleePI, Callee),
        permission_error(scasp, procedure, CalleePI)
    ).
body_calls(G, _, _) =>
    type_error(callable, G).

rm_classic_negation(-Goal, Goal) :-
    !.
rm_classic_negation(Goal, PGoal) :-
    functor(Goal, Name, _),
    atom_concat(-, Plain, Name),
    Goal  =.. [Name|Args],
    PGoal =.. [Plain|Args].

pm(P, P).
pm(M:P, M:MP) :-
    intern_negation(-P, MP).

implementation(M0:Head, M:Head) :-
    predicate_property(M0:Head, imported_from(M1)),
    !,
    M = M1.
implementation(Head, Head).

generalise(M:Head0, Gen), atom(M) =>
    Gen = M:Head,
    generalise(Head0, Head).
generalise(-Head0, Gen) =>
    Gen = -Head,
    generalise(Head0, Head).
generalise(Head0, Head) =>
    functor(Head0, Name, Arity),
    functor(Head, Name, Arity).

predicate_generation(Head, Gen) :-
    predicate_property(Head, last_modified_generation(Gen0)),
    !,
    Gen = Gen0.
predicate_generation(_, 0).


		 /*******************************
		 *            EXPAND		*
		 *******************************/

user:term_expansion(-Fact, MFact) :-
    callable(Fact),
    intern_negation(-Fact, MFact).
user:term_expansion((-Head :- Body), (MHead :- Body)) :-
    callable(Head),
    intern_negation(-Head, MHead).
user:term_expansion((false :- Body), ((-) :- Body)).

user:goal_expansion(-Goal, MGoal) :-
    callable(Goal),
    intern_negation(-Goal, MGoal).
