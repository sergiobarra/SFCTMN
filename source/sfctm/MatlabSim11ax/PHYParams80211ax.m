
function [Nsc,Ym,Yc,T_OFDM,Legacy_PHYH,HE_PHYH]=PHYParams80211ax(W,MCSindex,SUSS)
  
  % Header ------
  
  load('constants_sfctmn_framework.mat');
  
  % Physical Header (HE SU Format)
  Legacy_PHYH = 20E-6;
  %HE_PHYH = (16 + SUSS*4)*1E-6;
  HE_PHYH = (16 + SUSS*16)*1E-6;
  
  % Channel Width [MHz]
  switch W        
    case 2.5 
         Nsc = 26;
    case 5 
         Nsc = 52;
    case 10 
         Nsc = 102;    
    case 20 
         Nsc = 234;
    case 40
         Nsc = 468;    
    case 80
         Nsc = 980;
    case 160
         Nsc = 1960;          
    otherwise 
          Nsc = -1;           
  end
  
  % Modulation and Coding Scheme (MCS) - Without DCM!!!
  
  switch MCSindex        
    case MODULATION_BPSK_1_2 
         Ym = 1;
         Yc = 1/2;
    case MODULATION_QPSK_1_2  
         Ym = 2;
         Yc = 1/2;
    case MODULATION_QPSK_3_4  
         Ym = 2;
         Yc = 3/4;
    case MODULATION_16QAM_1_2  
         Ym = 4;
         Yc = 1/2;
    case MODULATION_16QAM_3_4  
         Ym = 4;
         Yc = 3/4;
    case MODULATION_64QAM_2_3  
         Ym = 6;
         Yc = 1/2;   
    case MODULATION_64QAM_3_4  
         Ym = 6;
         Yc = 2/3;  
    case MODULATION_64QAM_5_6  
         Ym = 6;
         Yc = 3/4;           
    case MODULATION_256QAM_3_4  
         Ym = 8;
         Yc = 3/4;   
    case MODULATION_256QAM_5_6  
         Ym = 8;
         Yc = 5/6;  
    case MODULATION_1024QAM_3_4  
         Ym = 10;
         Yc = 3/4;
    case MODULATION_1024QAM_5_6  
         Ym = 10;
         Yc = 5/6;
    otherwise 
        %disp('MCS code not found')
        Ym = -1;
        Yc = -1;
  end  
  % Duration of OFDM symbol (CP of 3.2us is included)
  T_OFDM = 4E-6;  
end