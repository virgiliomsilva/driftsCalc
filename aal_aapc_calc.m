function [aal_aapc] = aal_aapc_calc(hazard_curve,vul_coll_curve,rtP)

    %% Inputs
    % hazard_curve - matrix with the hazard curve [IMLs PoE]
    % vul_coll_curve - matrix containing either the vul curve or the collapse
    % fragilty curve depending if AAL or AAPC is needed
    % rtP - return period of the hazard curve (default 1)

    %% Outputs
    % aal_aapc - average annual loss or average annual probability of collapse
    % depening is vul curve or fragility curve is given 

    %%
    if nargin==2
        rtP=1;
    end
    
    curve_imls=vul_coll_curve(:,1)';
    curve_ordinates=vul_coll_curve(:,2)';
    
    meanIMLs = (hazard_curve(1:end-1,1)+hazard_curve(2:end,1))/2;
    rateOcc = (hazard_curve(1:end-1,2)/rtP)-(hazard_curve(2:end,2)/rtP);
    
    aal_aapc=sum(interp1([0 curve_imls 10],[0 curve_ordinates 1],meanIMLs,'linear',max([0 curve_ordinates 1])).*rateOcc);

end

