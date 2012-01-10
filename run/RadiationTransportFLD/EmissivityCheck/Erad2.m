function E = Erad2(nu,Ef,E1,E2,E3,rUnit)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage:  E = Erad2(nu,Ef,E1,E2,E3,rUnit)
%
% Input: nu - frequency to evaluate E(nu)
% Output:  E - radiation energy density at this frequency
%
% Daniel R. Reynolds
% 10.15.2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set input radiation values
E1rat = E1/Ef;
E2rat = E2/Ef;
E3rat = E3/Ef;

% set some parameters
hp = 6.6260693e-27;            % Planck's constant (ergs*s)
ev2erg = 1.60217653e-12;       % conversion constant from eV to ergs
c = 2.99792458e10;             % speed of light (cm/s)
nu0_HI   = 13.6*ev2erg/hp;     % ionization threshold of HI (hz)
nu0_HeI  = 24.6*ev2erg/hp;     % ionization threshold of HeI (hz)
nu0_HeII = 54.4*ev2erg/hp;     % ionization threshold of HeII (hz)

% compute chibar = int_{nu0}^{\infty} chi(nu) dnu
chibar = quadl('chifun',nu0_HI,10*nu0_HeII,1e-8);

% get the spectrum at the relevant frequencies
chinu = chifun(nu);

% compute the cross-sections at the frequency thresholds, and the input
% frequency
sig11 = sigHI(nu0_HI);
sig12 = sigHI(nu0_HeI);
sig13 = sigHI(nu0_HeII);
sig22 = sigHeI(nu0_HeI);
sig23 = sigHeI(nu0_HeII);
sig33 = sigHeII(nu0_HeII);
sig1nu = zeros(size(nu));
sig2nu = zeros(size(nu));
sig3nu = zeros(size(nu));
for i=1:length(nu)
   if (nu(i) >= nu0_HI)
      sig1nu(i) = sigHI(nu(i));
   end
   if (nu(i) >= nu0_HeI)
      sig2nu(i) = sigHeI(nu(i));
   end
   if (nu(i) >= nu0_HeII)
      sig3nu(i) = sigHeII(nu(i));
   end
end

% construct the S functions
S3 = sig3nu/sig33;
S2 = sig2nu/sig22 - sig23/sig22*S3;
S1 = sig1nu/sig11 - sig13/sig11*S3 - sig12/sig11*S2;

% combine terms to get E
E = zeros(size(nu));
for i=1:length(nu)
   if (nu(i) < nu0_HeI) 
      E(i) = Ef*rUnit*chinu(i)/chibar*(E1rat)^S1(i);
   elseif (nu(i) < nu0_HeII)
      E(i) = Ef*rUnit*chinu(i)/chibar*(E1rat)^S1(i)*(E2rat)^S2(i);
   else
      E(i) = Ef*rUnit*chinu(i)/chibar*(E1rat)^S1(i)*(E2rat)^S2(i)*(E3rat)^S3(i);
   end
end

% end function
