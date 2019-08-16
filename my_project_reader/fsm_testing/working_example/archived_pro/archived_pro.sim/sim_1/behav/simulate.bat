@echo off
set xv_path=C:\\Xilinx\\Vivado\\2016.1\\bin
call %xv_path%/xsim irig_testbench_behav -key {Behavioral:sim_1:Functional:irig_testbench} -tclbatch irig_testbench.tcl -view G:/my_project_reader/fsm_testing/working_example/archived_pro/irig_testbench_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
