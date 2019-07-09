% Input parameters
% - L: packet size (from network layer)
% - Na: Number of aggregated packets in an A-MPDU
% - W: RU size OFDMA (channel width in MHz!)
% - SUSS: Single-User Spatial Streams
% - MCSindex: Modulation and Coding Scheme index

% Author: Kostis Dovelos
% Changes: More MCS, and few minor changes in PHY and MAC input parameters (BB, 14-09-2017)

% RTS + SIFS + CTS + DATA + SIFS + ACK + DIFS + Te

function [T, limited_num_packets_aggregated, T_c]=SUtransmission80211ax(L,Na,W,SUSS,MCSindex,TimeoutFlag)



if MCSindex == -1
    
    T = 0;
    limited_num_packets_aggregated = 0;
    T_c = 0;
    
else 

    % Load 802.11ax parameters
    IEEE_AX_PHY_HE_SU_DURATION = 100e-6;
    IEEE_AX_MD_LENGTH = 32;
    IEEE_AX_MH_LENGTH = 320;
    IEEE_AX_OFDM_SYMBOL_GI32_DURATION = 16e-6;
    IEEE_AX_MAX_PPDU_DURATION = 5484e-6;

    %% MAC
    [DIFS,SIFS,Te,L_MACH,L_BACK,L_RTS,L_CTS,L_SF,L_DEL,L_TAIL]=MACParams80211ax();

    %% PHY
    [Nsc,Ym,Yc,T_OFDM,Legacy_PHYH,HE_PHYH]=PHYParams80211ax(W,MCSindex,SUSS);
    bits_ofdm_sym_legacy = 24;
    bits_ofdm_sym = Nsc * Ym * Yc * SUSS;
    % Rate = Nsc * Ym * Yc * SUSS;
    % Rate_20MHz = 52 * Ym * Yc; % In legacy mode

    %disp([Nsc Ym Yc]);

    % Duplicate RTS/CTS for bandwidth allocation
    T_RTS  = Legacy_PHYH + ceil((L_SF+L_RTS)/bits_ofdm_sym_legacy)*T_OFDM;
    T_CTS  = Legacy_PHYH + ceil((L_SF+L_CTS)/bits_ofdm_sym_legacy)*T_OFDM;

    if(TimeoutFlag) 
        T = T_RTS + DIFS;
    else 
        % LIMIT OF THE NUMBER OF AGG PACKETS
        limited_num_packets_aggregated = Na;
        while (limited_num_packets_aggregated > 0)
            T_DATA = IEEE_AX_PHY_HE_SU_DURATION + ceil((L_SF + limited_num_packets_aggregated ...
                * (IEEE_AX_MD_LENGTH + IEEE_AX_MH_LENGTH + L)) / bits_ofdm_sym) * IEEE_AX_OFDM_SYMBOL_GI32_DURATION;
            if(T_DATA <= IEEE_AX_MAX_PPDU_DURATION) 
                break;
            else
                limited_num_packets_aggregated = limited_num_packets_aggregated - 1;
            end
        end
        % After successful acquisition of the channel
        % T_DATA = IEEE_AX_PHY_HE_SU_DURATION + ceil((L_SF + limited_num_packets_aggregated * ...
        %     (IEEE_AX_MD_LENGTH + IEEE_AX_MH_LENGTH + L)) / bits_ofdm_sym) * IEEE_AX_OFDM_SYMBOL_GI32_DURATION;

        T_BACK = 32e-6;%Legacy_PHYH + ceil((L_SF+L_BACK+L_TAIL)/Rate_20MHz)*T_OFDM;

        % Successful slot
        T = T_RTS + SIFS + T_CTS + SIFS + T_DATA + SIFS + T_BACK + DIFS + Te; % (Implicit BACK request)

        % Collision slot
        T_c = T_RTS + SIFS + T_CTS + DIFS + Te;
    end
    
end
    
end