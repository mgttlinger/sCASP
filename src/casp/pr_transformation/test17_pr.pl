pr_rule(p,[not(q)]).
pr_rule(not(q),[]).
pr_rule(not(o_p1),[q]).
pr_rule(not(p),[not(o_p1)]).
pr_rule(not(o__false1),[p]).
pr_rule(not(o_false),[not(o__false1)]).
pr_rule(not(o__chk11),[p]).
pr_rule(not(o_chk1),[not(o__chk11)]).
pr_rule(not(o_false),[]).
pr_rule(o_nmr_check,[not(o_chk1)]).
pr_rule(add_to_query,[o_nmr_check]).
