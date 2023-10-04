
    #include "lib.h"

    char buffer[100];
    int number = 2331;

    #define NULL 0

    void run_operation(int op){
        int val;
        Node node_45,head_node,node_95,node_110,node_98,node_7,node_1,node_85,node_61,node_11,node_16,node_107,node_47,node_13,node_120,node_24,node_122,node_35,node_106,node_18,node_36,node_87,node_39,node_17,node_62,node_38,node_103,node_55,node_81,node_89,node_40,node_33,node_25,node_14,node_111,node_97,node_114,node_65,node_46,node_83,node_127,node_67,node_123,node_32,node_63,node_91,node_78,node_66,node_84,node_96,node_117,node_28,node_80,node_71,node_68,node_20,node_92,node_109,node_26,node_118,node_121,node_101,node_93,node_48,node_72,node_4,node_42,node_73,node_19,node_21,node_60,node_102,node_77,node_49,node_9,node_12,node_10,node_23,node_94,node_104,node_115,node_69,node_30,node_126,node_112,node_116,node_105,node_44,node_64,node_6,node_50,node_82,node_22,node_2,node_124,node_15,node_58,node_57,node_3,node_54,node_51,node_8,node_56,node_37,node_74,node_100,node_113,node_29,node_75,node_34,node_88,node_70,node_53,node_5,node_99,node_43,node_31,node_90,node_108,node_119,node_79,node_76,node_59,node_27,node_41,node_86,node_52,node_125;
        head_node.val1 = 10;head_node.val2 = -4;head_node.next = &node_1;
        node_1.val1 = 56;node_1.val2 = 78;node_1.next = &node_2;
        node_2.val1 = -654;node_2.val2 = 590;node_2.next = &node_3;
        node_3.val1 = -100;node_3.val2 = -43;node_3.next = &node_4;
        node_4.val1 = 9854;node_4.val2 = -7376;node_4.next = &node_5;
        node_5.val1 = 8506;node_5.val2 = -3387;node_5.next = &node_6;
        node_6.val1 = -5023;node_6.val2 = 12789;node_6.next = &node_7;
        node_7.val1 = 8185;node_7.val2 = -7391;node_7.next = &node_8;
        node_8.val1 = -9942;node_8.val2 = 16720;node_8.next = &node_9;
        node_9.val1 = 5799;node_9.val2 = -11990;node_9.next = &node_10;
        node_10.val1 = -9712;node_10.val2 = 14658;node_10.next = &node_11;
        node_11.val1 = -3420;node_11.val2 = 8699;node_11.next = &node_12;
        node_12.val1 = -4305;node_12.val2 = 5570;node_12.next = &node_13;
        node_13.val1 = -235;node_13.val2 = -3251;node_13.next = &node_14;
        node_14.val1 = 8738;node_14.val2 = -6742;node_14.next = &node_15;
        node_15.val1 = 4256;node_15.val2 = -9805;node_15.next = &node_16;
        node_16.val1 = 8856;node_16.val2 = -10983;node_16.next = &node_17;
        node_17.val1 = 659;node_17.val2 = -1474;node_17.next = &node_18;
        node_18.val1 = 6044;node_18.val2 = 3244;node_18.next = &node_19;
        node_19.val1 = 9482;node_19.val2 = -18580;node_19.next = &node_20;
        node_20.val1 = -9310;node_20.val2 = 14690;node_20.next = &node_21;
        node_21.val1 = -7042;node_21.val2 = 7337;node_21.next = &node_22;
        node_22.val1 = -325;node_22.val2 = 10020;node_22.next = &node_23;
        node_23.val1 = -2138;node_23.val2 = 2546;node_23.next = &node_24;
        node_24.val1 = 3302;node_24.val2 = -5226;node_24.next = &node_25;
        node_25.val1 = -7751;node_25.val2 = 10970;node_25.next = &node_26;
        node_26.val1 = 1689;node_26.val2 = -10398;node_26.next = &node_27;
        node_27.val1 = -142;node_27.val2 = 4619;node_27.next = &node_28;
        node_28.val1 = -3364;node_28.val2 = 6352;node_28.next = &node_29;
        node_29.val1 = 5383;node_29.val2 = 2597;node_29.next = &node_30;
        node_30.val1 = -7939;node_30.val2 = 2692;node_30.next = &node_31;
        node_31.val1 = 1144;node_31.val2 = 3837;node_31.next = &node_32;
        node_32.val1 = -1028;node_32.val2 = 9818;node_32.next = &node_33;
        node_33.val1 = 2390;node_33.val2 = -422;node_33.next = &node_34;
        node_34.val1 = 930;node_34.val2 = 550;node_34.next = &node_35;
        node_35.val1 = 8319;node_35.val2 = -17692;node_35.next = &node_36;
        node_36.val1 = 3444;node_36.val2 = 3110;node_36.next = &node_37;
        node_37.val1 = 9382;node_37.val2 = -2595;node_37.next = &node_38;
        node_38.val1 = 9564;node_38.val2 = -19313;node_38.next = &node_39;
        node_39.val1 = -9465;node_39.val2 = 2066;node_39.next = &node_40;
        node_40.val1 = 8915;node_40.val2 = -17725;node_40.next = &node_41;
        node_41.val1 = -1349;node_41.val2 = -6195;node_41.next = &node_42;
        node_42.val1 = 8403;node_42.val2 = -6418;node_42.next = &node_43;
        node_43.val1 = 6819;node_43.val2 = -1206;node_43.next = &node_44;
        node_44.val1 = 7872;node_44.val2 = -16178;node_44.next = &node_45;
        node_45.val1 = -3395;node_45.val2 = -4760;node_45.next = &node_46;
        node_46.val1 = 9776;node_46.val2 = -1400;node_46.next = &node_47;
        node_47.val1 = -4303;node_47.val2 = 14004;node_47.next = &node_48;
        node_48.val1 = -5357;node_48.val2 = -2259;node_48.next = &node_49;
        node_49.val1 = 6196;node_49.val2 = -2279;node_49.next = &node_50;
        node_50.val1 = 5189;node_50.val2 = -1298;node_50.next = &node_51;
        node_51.val1 = 1658;node_51.val2 = -8733;node_51.next = &node_52;
        node_52.val1 = -166;node_52.val2 = 7251;node_52.next = &node_53;
        node_53.val1 = 7316;node_53.val2 = -16400;node_53.next = &node_54;
        node_54.val1 = 1891;node_54.val2 = 6601;node_54.next = &node_55;
        node_55.val1 = 288;node_55.val2 = 9437;node_55.next = &node_56;
        node_56.val1 = 3159;node_56.val2 = -5881;node_56.next = &node_57;
        node_57.val1 = -5232;node_57.val2 = 14712;node_57.next = &node_58;
        node_58.val1 = 1742;node_58.val2 = -5895;node_58.next = &node_59;
        node_59.val1 = 9497;node_59.val2 = -14197;node_59.next = &node_60;
        node_60.val1 = 3727;node_60.val2 = -12971;node_60.next = &node_61;
        node_61.val1 = -2178;node_61.val2 = -7286;node_61.next = &node_62;
        node_62.val1 = -1102;node_62.val2 = -5824;node_62.next = &node_63;
        node_63.val1 = 4632;node_63.val2 = 355;node_63.next = &node_64;
        node_64.val1 = -4207;node_64.val2 = 4630;node_64.next = &node_65;
        node_65.val1 = 6453;node_65.val2 = -7996;node_65.next = &node_66;
        node_66.val1 = 6003;node_66.val2 = 2623;node_66.next = &node_67;
        node_67.val1 = -718;node_67.val2 = 3637;node_67.next = &node_68;
        node_68.val1 = -202;node_68.val2 = 5584;node_68.next = &node_69;
        node_69.val1 = 6909;node_69.val2 = -12602;node_69.next = &node_70;
        node_70.val1 = 2119;node_70.val2 = 545;node_70.next = &node_71;
        node_71.val1 = -2390;node_71.val2 = 1147;node_71.next = &node_72;
        node_72.val1 = 5559;node_72.val2 = -10043;node_72.next = &node_73;
        node_73.val1 = 3083;node_73.val2 = -1582;node_73.next = &node_74;
        node_74.val1 = -3169;node_74.val2 = -3295;node_74.next = &node_75;
        node_75.val1 = 9590;node_75.val2 = -5029;node_75.next = &node_76;
        node_76.val1 = -1821;node_76.val2 = -3210;node_76.next = &node_77;
        node_77.val1 = -412;node_77.val2 = 7182;node_77.next = &node_78;
        node_78.val1 = 7392;node_78.val2 = -9375;node_78.next = &node_79;
        node_79.val1 = -707;node_79.val2 = -1099;node_79.next = &node_80;
        node_80.val1 = -5425;node_80.val2 = -1640;node_80.next = &node_81;
        node_81.val1 = -9858;node_81.val2 = 16310;node_81.next = &node_82;
        node_82.val1 = -8969;node_82.val2 = 7807;node_82.next = &node_83;
        node_83.val1 = -7538;node_83.val2 = 10840;node_83.next = &node_84;
        node_84.val1 = -4993;node_84.val2 = 8341;node_84.next = &node_85;
        node_85.val1 = 5953;node_85.val2 = -6219;node_85.next = &node_86;
        node_86.val1 = 7742;node_86.val2 = -13026;node_86.next = &node_87;
        node_87.val1 = -9890;node_87.val2 = 11295;node_87.next = &node_88;
        node_88.val1 = -2803;node_88.val2 = -2023;node_88.next = &node_89;
        node_89.val1 = -72;node_89.val2 = -8881;node_89.next = &node_90;
        node_90.val1 = 3810;node_90.val2 = -11056;node_90.next = &node_91;
        node_91.val1 = -4953;node_91.val2 = 13021;node_91.next = &node_92;
        node_92.val1 = -3333;node_92.val2 = 10371;node_92.next = &node_93;
        node_93.val1 = -522;node_93.val2 = -5898;node_93.next = &node_94;
        node_94.val1 = 4104;node_94.val2 = -2868;node_94.next = &node_95;
        node_95.val1 = -432;node_95.val2 = -8702;node_95.next = &node_96;
        node_96.val1 = 2565;node_96.val2 = 1836;node_96.next = &node_97;
        node_97.val1 = -5283;node_97.val2 = 13685;node_97.next = &node_98;
        node_98.val1 = 7164;node_98.val2 = 1296;node_98.next = &node_99;
        node_99.val1 = -4393;node_99.val2 = 4335;node_99.next = &node_100;
        node_100.val1 = -3522;node_100.val2 = 11241;node_100.next = &node_101;
        node_101.val1 = 9604;node_101.val2 = -8314;node_101.next = &node_102;
        node_102.val1 = 8804;node_102.val2 = -10113;node_102.next = &node_103;
        node_103.val1 = -6430;node_103.val2 = -2536;node_103.next = &node_104;
        node_104.val1 = -5833;node_104.val2 = -3011;node_104.next = &node_105;
        node_105.val1 = -6661;node_105.val2 = 12775;node_105.next = &node_106;
        node_106.val1 = -9905;node_106.val2 = 9237;node_106.next = &node_107;
        node_107.val1 = -5004;node_107.val2 = 6924;node_107.next = &node_108;
        node_108.val1 = 2327;node_108.val2 = -4315;node_108.next = &node_109;
        node_109.val1 = 3390;node_109.val2 = 6299;node_109.next = &node_110;
        node_110.val1 = 4246;node_110.val2 = -7060;node_110.next = &node_111;
        node_111.val1 = 784;node_111.val2 = -1037;node_111.next = &node_112;
        node_112.val1 = -4997;node_112.val2 = 1800;node_112.next = &node_113;
        node_113.val1 = -5327;node_113.val2 = 8466;node_113.next = &node_114;
        node_114.val1 = 3945;node_114.val2 = 5455;node_114.next = &node_115;
        node_115.val1 = -3318;node_115.val2 = 1792;node_115.next = &node_116;
        node_116.val1 = -719;node_116.val2 = 7961;node_116.next = &node_117;
        node_117.val1 = 9238;node_117.val2 = -3793;node_117.next = &node_118;
        node_118.val1 = -5030;node_118.val2 = -2932;node_118.next = &node_119;
        node_119.val1 = 6226;node_119.val2 = 560;node_119.next = &node_120;
        node_120.val1 = -3890;node_120.val2 = 8272;node_120.next = &node_121;
        node_121.val1 = -7350;node_121.val2 = 10806;node_121.next = &node_122;
        node_122.val1 = 545;node_122.val2 = -2532;node_122.next = &node_123;
        node_123.val1 = -5288;node_123.val2 = -1527;node_123.next = &node_124;
        node_124.val1 = 3963;node_124.val2 = -3211;node_124.next = &node_125;
        node_125.val1 = 3360;node_125.val2 = -9969;node_125.next = &node_126;
        node_126.val1 = -7612;node_126.val2 = 3897;node_126.next = &node_127;
        node_127.val1 = 6490;node_127.val2 = -11401;node_127.next = NULL;
        
        switch (op){
            case 0:
                puts(buffer);
                break;

            case 1:
                gets(buffer);
                puts(buffer);
                break;

            case 2:
                puts(itoa(number, buffer, 10));
                break;

            case 3:
                puts(itoa(atoi(gets(buffer)), buffer, 16));
                break;

            case 4:
                gets(buffer);
                puts(buffer);
                gets(buffer);
                puts(buffer);
                break;

            case 5:
                val = atoi(gets(buffer));
                puts(itoa(linked_list_search(&head_node, val), buffer, 10));
                break;
            
            default:
                break;
            }
    }

    void _start(){
        int operation = atoi(gets(buffer));
        run_operation(operation);
        exit(0);
    }
    