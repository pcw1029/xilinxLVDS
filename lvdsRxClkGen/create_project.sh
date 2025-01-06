rm -rf project_*
if [ -f script/project_lvdsRxClkGen.tcl ]; then
	echo " "
	echo "##### CREATE ${D} PROJECT START #####"
	vivado -mode batch -source script/project_lvdsRxClkGen.tcl 
	echo "##### CREATE ${D} PROJECT DONE #####"
fi
