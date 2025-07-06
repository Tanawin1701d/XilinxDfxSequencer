proc run_dfx4ml {myRepoPath AMT_DFX} {

    ### change the directory

    # set myRepoPath "/media/tanawin/tanawin1701e/project6/hls4mlCustomIps"
    # set AMT_DFX 3

    set myprjName "zcu102dfxCtrl2Renew"
    set PR_NAME_BASE "DFX4ML_PAR0"
    cd $myprjName


    ### set up ip repository to HLS4ML
    set allRepoPath [get_property ip_repo_paths [current_project]]
    lappend allRepoPath $myRepoPath
    set_property ip_repo_paths $allRepoPath [current_project]
    update_ip_catalog -rebuild -scan_changes


    ### open system block design and set as current design
    set system_bd_path [file normalize "./zcu102dfxCtrl2Renew.srcs/sources_1/bd/system/system.bd"]
    open_bd_design $system_bd_path
    validate_bd_design
    set curdesign [current_bd_design]

    ### auto build layout for each partial reconfig
    for {set dfxId 1} {$dfxId <= $AMT_DFX} {incr dfxId} {


        set dfx_bd_name "${PR_NAME_BASE}_ML${dfxId}"

        ### build and open it
        create_bd_design -boundary_from_container [get_bd_cells /${PR_NAME_BASE}] $dfx_bd_name
        open_bd_design ./zcu102dfxCtrl2Renew.srcs/sources_1/bd/${dfx_bd_name}/${dfx_bd_name}.bd

        ### enter the place we want to go
            ### get back to the system to ensure where we are
        current_bd_design $curdesign
            ### enter current block design
        current_bd_design [get_bd_designs $dfx_bd_name]
            ### I don't know what i do in this line
        update_compile_order -fileset sources_1
        ### load our ip and connect it
        set hls_ip_type "myproject_graph${dfxId}_axi"
        set hls_ip_name "${hls_ip_type}_0"
        puts ${hls_ip_name}
        startgroup
        create_bd_cell -type ip -vlnv "xilinx.com:hls:${hls_ip_type}:1.0" "${hls_ip_name}"
        endgroup
        
        connect_bd_intf_net [get_bd_intf_ports A]   [get_bd_intf_pins "${hls_ip_name}/in_r"]
        connect_bd_net      [get_bd_ports ap_clk]   [get_bd_pins "${hls_ip_name}/ap_clk"]
        connect_bd_net      [get_bd_ports ap_rst_n] [get_bd_pins "${hls_ip_name}/ap_rst_n"]
        connect_bd_intf_net [get_bd_intf_ports B]   [get_bd_intf_pins "${hls_ip_name}/out_r"]

        validate_bd_design
        save_bd_design

        close_bd_design [get_bd_designs $dfx_bd_name]

        ### get back to the system

        current_bd_design [get_bd_designs system]
        validate_bd_design

        ### generate block
    }

    ### assign the new built block design to host partial region
    set sim_bd_list "${PR_NAME_BASE}.bd"
    set synth_bd_list "${PR_NAME_BASE}.bd"

    for {set dfxId 1} {$dfxId <= $AMT_DFX} {incr dfxId} {
        set dfx_bd_name "${PR_NAME_BASE}_ML${dfxId}"
        append sim_bd_list ":${dfx_bd_name}.bd"
        append synth_bd_list ":${dfx_bd_name}.bd"
    }

    set_property -dict [list \
        CONFIG.LIST_SIM_BD $sim_bd_list \
        CONFIG.LIST_SYNTH_BD $synth_bd_list \
    ] [get_bd_cells ${PR_NAME_BASE}]



    ### generate block design
    
    generate_target all [get_files $system_bd_path]
    export_ip_user_files -of_objects [get_files $system_bd_path] -no_script -sync -force -quiet
    create_ip_run [get_files -of_objects [get_fileset sources_1] $system_bd_path]

    #### do synthesis

    launch_runs [get_runs *synth*] -jobs 8
    wait_on_run synth_1

    #### config the partial configuration
    delete_runs "myImpl"
    set runName "dfxImp"
    set runPoolNames "${runName}"
    set runPoolChildOnly ""
    create_run $runName -parent_run synth_1 -flow {Vivado Implementation 2023} -pr_config config_test -dfx_mode STANDARD


    for {set dfxId 1} {$dfxId <= $AMT_DFX} {incr dfxId} {
        set dfx_bd_name   "${PR_NAME_BASE}_ML${dfxId}"
        set config_name   "config_m${dfxId}"
        set childImp_name "child_${dfxId}_${runName}"
        create_pr_configuration -name ${config_name} -partitions [ list system_i/${PR_NAME_BASE}:${dfx_bd_name}_inst_0 ]
        ##### if this is changed, the destination of the binstream must be changed as well
        create_run ${childImp_name} -parent_run ${runName} -flow {Vivado Implementation 2023} -pr_config ${config_name}
        append runPoolNames " ${childImp_name}"
        append runPoolChildOnly " ${childImp_name}"

    }

    #### do implementation
    current_run [get_runs ${runName}]
    launch_runs $runPoolNames -jobs 8

    #### wait on implementation
    foreach runNamef $runPoolNames {
        wait_on_run $runNamef
    }

    #### generate bitstream
    foreach runNamef $runPoolNames {
        set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs ${runNamef}]
        launch_runs ${runNamef} -to_step write_bitstream -jobs 1
    }

    foreach runNamef $runPoolNames {
        wait_on_run $runNamef
    }


    #### make output directory
    file mkdir output

    #### copy bitstream and hardware handoff file (main file)
    file copy -force ${myprjName}.runs/$runName/system_wrapper.bin output/system.bin
    file copy -force ${myprjName}.gen/sources_1/bd/system/hw_handoff/system.hwh output/system.hwh

    #### copy the partial bit stream
    for {set dfxId 1} {$dfxId <= $AMT_DFX} {incr dfxId} {
        set dfx_bd_name   "${PR_NAME_BASE}_ML${dfxId}"
        set childImp_name "child_${dfxId}_${runName}"
        set sub_cell_name "system_i_${PR_NAME_BASE}_${dfx_bd_name}_inst_0"
        set run_cell_name "${dfx_bd_name}_inst_0"

        set tgName "dfx4ml${dfxId}"

        #### copy the bin stream file
        file copy -force ${myprjName}.runs/${childImp_name}/${sub_cell_name}_partial.bin  output/${tgName}.bin
        #### copy the hwh file 
        file copy -force ${myprjName}.gen/sources_1/bd/system/bd/${run_cell_name}/hw_handoff/${run_cell_name}.hwh output/${tgName}.hwh
    }

    #### copy dfx reconfig file

    file copy -force ${myprjName}.gen/sources_1/bd/system/ip/system_dfx_controller_0_1/documentation/configuration_information.txt output/dfxCtrlMeta.txt 


}



run_dfx4ml "/media/tanawin/tanawin1701e/project6/hls4mlCustomIps" 3