pr_rule(p(X),[not(q(X))]).
pr_rule(q(X),[not(p(X))]).
pr_rule(r(X),[X\=1,X\=2,p(X),not(r(X))]).
pr_rule(s(X),[X\=2,p(X),not(s(X))]).
pr_rule(not(o_s1(X)),[X=2]).
pr_rule(not(o_s1(X)),[X\=2,not(p(X))]).
pr_rule(not(o_s1(X)),[X\=2,p(X),s(X)]).
pr_rule(not(s(_X0)),[not(o_s1(_X0))]).
pr_rule(not(o_r1(X)),[X=1]).
pr_rule(not(o_r1(X)),[X\=1,X=2]).
pr_rule(not(o_r1(X)),[X\=1,X\=2,not(p(X))]).
pr_rule(not(o_r1(X)),[X\=1,X\=2,p(X),r(X)]).
pr_rule(not(r(_X0)),[not(o_r1(_X0))]).
pr_rule(not(o_q1(X)),[p(X)]).
pr_rule(not(q(_X0)),[not(o_q1(_X0))]).
pr_rule(not(o_p1(X)),[q(X)]).
pr_rule(not(p(_X0)),[not(o_p1(_X0))]).
pr_rule(not(o_false),[]).
pr_rule(not(o__chk11(X)),[X=1]).
pr_rule(not(o__chk11(X)),[X\=1,X=2]).
pr_rule(not(o__chk11(X)),[X\=1,X\=2,not(p(X))]).
pr_rule(not(o__chk11(X)),[X\=1,X\=2,p(X),r(X)]).
pr_rule(not(o_chk1(_X0)),[not(o__chk11(_X0))]).
pr_rule(not(o__chk21(X)),[X=2]).
pr_rule(not(o__chk21(X)),[X\=2,not(p(X))]).
pr_rule(not(o__chk21(X)),[X\=2,p(X),s(X)]).
pr_rule(not(o_chk2(_X0)),[not(o__chk21(_X0))]).
pr_rule(not(o_false),[]).
pr_rule(o_nmr_check,[forall(_X0,not(o_chk1(_X0))),forall(_X0,not(o_chk2(_X0)))]).
pr_rule(add_to_query,[o_nmr_check]).
