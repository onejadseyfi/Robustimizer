% Robustimizer - Copyright (c) 2024 Omid Nejadseyfi
% Licensed under the GNU General Public License v3.0, see LICENSE.md.
function [DOE]=MakeDOE(np,nDOE,cp,mmi)

% This function generates the DOE based on the given settings

% Input: 
% np        number of parameters
% nDOE      number of DOE points
% cp        parameter to consider factorial design
% mmi       parameter to include maxmizing the minimum distance

% OutPut: 
% DOE       Design of experiment with nDOE*np size

if cp==0
    if mmi==1
        DOE=lhsdesign(nDOE,np,'criterion','maximin','iterations',1000); 
    else
        DOE=lhsdesign(nDOE,np);
    end
else
    % Generate factorial design
    switch np 
        case 2 
            [DOEcp] = fracfact('a b'); 
        case 3
            [DOEcp] = fracfact('a b ab'); 
        case 4  	
            [DOEcp] = fracfact('a b c abc'); 
        case 5  	
            [DOEcp] = fracfact('a b c ab ac'); 
        case 6  	
            [DOEcp] = fracfact('a b c ab ac bc'); 
        case 7  	
            [DOEcp] = fracfact('a b c ab ac bc abc'); 
        case 8  	
            [DOEcp] = fracfact('a b c d bcd acd abc abd'); 
        case 9  	
            [DOEcp] = fracfact('a b c d abc bcd acd abd abcd'); 
        case 10  	
            [DOEcp] = fracfact('a b c d abc bcd acd abd abcd ab');
    end

    if mmi==1
        DOE_LHS=lhsdesign(nDOE-size(DOEcp,1),np,'criterion','maximin','iterations',1000);
    else
        DOE_LHS=lhsdesign(nDOE-size(DOEcp,1),np);
    end  
    %Combine factorial design with LHS
    DOE=[DOEcp./2+0.5;DOE_LHS];
end
 