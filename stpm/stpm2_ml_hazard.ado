program stpm2_ml_hazard	
	version 11.0
	args todo b lnf g H g1 g2 g3	
	tempvar xb dxb
	mleval `xb' = `b', eq(1)
	mleval `dxb' = `b', eq(2)
	
	local del_entry 0
	qui summ _t0 , meanonly
	if r(max)>0 {
		local del_entry = 1
		tempvar xb0 d_xb0 d33 d13 d23
		mleval `xb0' = `b', eq(3)
		local lnst0 +cond(_t0>0,exp(`xb0'),0)
	}
	local st exp(-exp(`xb'))
	local ht `dxb'*exp(`xb') 
	quietly {
		mlsum `lnf' = _d*ln(`ht') + ln(`st') `lnst0'
		if (`todo' == 0 | `lnf' >=.) exit
		qui replace `g1' = _d - exp(`xb')
		qui replace `g2' = _d/(`dxb')

		tempname d_dxb d_xb
		mlvecsum `lnf' `d_xb' = `g1', eq(1)
		mlvecsum `lnf' `d_dxb' = `g2', eq(2)
		if `del_entry' == 1 {
			replace `g3' =  cond(_t0>0,exp(`xb0'),0)
			mlvecsum `lnf' `d_xb0' = `g3', eq(3)
			matrix `g' = (`d_xb',`d_dxb',`d_xb0')
		}
		else {
			matrix `g' = (`d_xb',`d_dxb')
		}

		if (`todo' == 1 | `lnf' >=.) exit

		tempname d11 d12 d22
		mlmatsum `lnf' `d11' =  exp(`xb'), eq(1)
		mlmatsum `lnf' `d12' = 0, eq(1,2)
		mlmatsum `lnf' `d22' = cond(_d==1, 1/(`dxb'*`dxb'),0), eq(2)
		if `del_entry' == 1 {
			mlmatsum `lnf' `d33' =  cond(_t0>0,-exp(`xb0'),0), eq(3)
			mlmatsum `lnf' `d13' =  0, eq(1,3)
			mlmatsum `lnf' `d23' =  0, eq(2,3)
			matrix `H' = -(`d11',`d12',`d13' \ `d12'',`d22',`d23' \ `d13'', `d23'', `d33')
		}
		else {
			matrix `H' = -(`d11',`d12' \ `d12'',`d22')			
		}
	}
end

