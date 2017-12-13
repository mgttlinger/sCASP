pr_rule(hold(T),[.>.(T,0)]).
pr_rule(hold(T),[.<.(T,Td),drop(Td),not(falling(T)),not(broken(T))]).
pr_rule(falling(T),[not(hold(T)),not(broken(T))]).
pr_rule(broken(T),[not(hold(T)),not(falling(T))]).
pr_rule(drop(2),[]).
pr_rule(not(o_broken1(T)),[hold(T)]).
pr_rule(not(o_broken1(T)),[not(hold(T)),falling(T)]).
pr_rule(not(broken(_X0)),[not(o_broken1(_X0))]).
pr_rule(not(o_falling1(T)),[hold(T)]).
pr_rule(not(o_falling1(T)),[not(hold(T)),broken(T)]).
pr_rule(not(falling(_X0)),[not(o_falling1(_X0))]).
pr_rule(not(o_drop1(_X0)),[_X0\=2]).
pr_rule(not(drop(_X0)),[not(o_drop1(_X0))]).
pr_rule(not(o_hold1(T)),[.=<.(T,0)]).
pr_rule(not(o_hold2(T,Td)),[.>=.(T,Td)]).
pr_rule(not(o_hold2(T,Td)),[.<.(T,Td),not(drop(Td))]).
pr_rule(not(o_hold2(T,Td)),[.<.(T,Td),drop(Td),falling(T)]).
pr_rule(not(o_hold2(T,Td)),[.<.(T,Td),drop(Td),not(falling(T)),broken(T)]).
pr_rule(not(o_hold2(T)),[forall(Td,not(o_hold2(T,Td)))]).
pr_rule(not(hold(_X0)),[not(o_hold1(_X0)),not(o_hold2(_X0))]).
pr_rule(not(o_false),[]).
pr_rule(not(o__chk11(T)),[hold(T)]).
pr_rule(not(o__chk11(T)),[not(hold(T)),falling(T)]).
pr_rule(not(o__chk11(T)),[not(hold(T)),not(falling(T)),broken(T)]).
pr_rule(not(o_chk1(_X0)),[not(o__chk11(_X0))]).
pr_rule(not(o__chk21(T)),[hold(T)]).
pr_rule(not(o__chk21(T)),[not(hold(T)),broken(T)]).
pr_rule(not(o__chk21(T)),[not(hold(T)),not(broken(T)),falling(T)]).
pr_rule(not(o_chk2(_X0)),[not(o__chk21(_X0))]).
pr_rule(not(o__chk31(T,Td)),[.>=.(T,Td)]).
pr_rule(not(o__chk31(T,Td)),[.<.(T,Td),not(drop(Td))]).
pr_rule(not(o__chk31(T,Td)),[.<.(T,Td),drop(Td),falling(T)]).
pr_rule(not(o__chk31(T,Td)),[.<.(T,Td),drop(Td),not(falling(T)),broken(T)]).
pr_rule(not(o__chk31(T,Td)),[.<.(T,Td),drop(Td),not(falling(T)),not(broken(T)),hold(T)]).
pr_rule(not(o__chk31(T)),[forall(Td,not(o__chk31(T,Td)))]).
pr_rule(not(o_chk3(_X0)),[not(o__chk31(_X0))]).
pr_rule(not(o_false),[]).
pr_rule(o_nmr_check,[forall(_X0,not(o_chk1(_X0))),forall(_X0,not(o_chk2(_X0))),forall(_X0,not(o_chk3(_X0)))]).
pr_rule(add_to_query,[o_nmr_check]).
