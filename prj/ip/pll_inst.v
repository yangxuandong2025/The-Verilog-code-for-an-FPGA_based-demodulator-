pll	pll_inst (
	.areset ( areset_sig ),
	.inclk0 ( inclk0_sig ),
	.c0 ( c0_sig ),//100M
	.c1 ( c1_sig ),//6M
	.c2 ( c2_sig ),//6M
	.locked ( locked_sig )
	);
