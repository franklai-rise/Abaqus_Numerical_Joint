C************************************************************* 
C 3-D damage criterion based on strain 
C*************************************************************
      Subroutine vumat ( 
C Read only       
     &nblock, ndir, nshr, nstatev, nfield, nprops, lanneal,       
     &stepTime, totalTime, dt, cmname, coordMp, charLength,       
     &props, density, StrainInc, relSpinInc,       
     &tempOld, stretchOld, defgradOld, fieldOld,       
     &stressOld, stateOld, enerInternOld, enerInelasOld,       
     &tempNew, stretchNew, defgradNew, fieldNew,  
     &StressNew, stateNew, enerInternNew, enerInelasNew) 
C       
      include 'vaba_param.inc' 
C        
      dimension  props(nprops), density(nblock), coordMp(nblock,*),       
     &charLength(nblock), StrainInc(nblock, ndir+nshr),       
     &relSpinInc(nblock, nshr), tempOld(nblock),        
     &stretchOld(nblock, ndir+nshr),        
     &defgradOld(nblock, ndir+nshr+nshr),       
     &fieldOld(nblock, nfield), StressOld(nblock, ndir+nshr),       
     &stateOld(nblock, nstatev), enerInternOld(nblock),       
     &enerInelasOld(nblock), tempNew(nblock),       
     &stretchNew(nblock, ndir+nshr),        
     &defgradNew(nblock, ndir+nshr+nshr),       
     &fieldNew(nblock, nfield),        
     &stressNew(nblock, ndir+nshr),stateNew(nblock, nstatev),       
     &enerInternNew(nblock),enerInelasNew(nblock) 
C        
      real Xt,Xc,Yt,Yc,S12,S13,S23, v21, v31, v32,
     &XE11, XE22, XE33, XG12, XG13, XG23,
     &XV12, XV13, XV23, XV21, XV31, XV32,
     &Xte,Xce,Yte,Yce,S12e,S13e,S23e,
     &eft,efc,emt,emc,ems,ems12,
     &fact, factor,  
     &sr11,sr22,sr33,sr12,sr23,sr13,
     &Xta,Xca,Yta,Yca,S12a,S13a,S23a,
     &E11a, E22a, E33a, G12a, G13a, G23a,
     &Xtb,Xcb,Ytb,Ycb,S12b,S13b,S23b,
     &E11b, E22b, E33b, G12b, G13b, G23b,
     &sr0

c      
      integer i        
      dimension C(6,6)        
      character*80 cmname  
c   
      parameter (zero = 0.d0, one = 1.d0 , two = 2.d0,
     &three = 3.d0, third = 1.d0 / 3.d0, half = 0.5d0, k = 1.d0) 
c------------------------------------------------------- 
C    statenew(*,1) = strain component 11 
C    statenew(*,2) = strain component 22 
C    statenew(*,3) = strain component 33 
C    statenew(*,4) = strain component 12 
C    statenew(*,5) = strain component 23 
C    statenew(*,6) = strain component 13 
c 
c    stateNew(i,7)     X fiber tension damage coefficient
c    stateNew(i,8)     X fiber compressive damage coefficient
c    stateNew(i,9)     X fiber damage coefficient
c    stateNew(i,10)    Y and Z matrix tension damage coefficient
c    stateNew(i,11)    Y and Z matrix compressive damage coefficient
c    stateNew(i,12)    YZ matrix damage coefficient
c    stateNew(i,13)    Z Shear damage coefficient
c    stateNew(i,14)    total damage 
c    stateNew(i,15)    Delete mark 
c    stateNew(i,16)    X fiber tension damage initiation criterion-------------eft      
c    stateNew(i,17)    X fiber compressive damage intiation criterion----------efc
c    stateNew(i,18)    Y and Z matrix tension damage initiation criterion------emt
c    stateNew(i,19)    Y and Z matrix compressive damage initiation criterion--emc
c    stateNew(i,20)    XZ and YZ shear damage initiaten criterion---------ems
c    stateNew(i,21)    XY shear damage initiaten criterion---------ems
c    stateNew(i,22)    XY shear damage coefficient  

C------------------ User needs to input-------------------------- 
C    props(1)     Xt  X fiber tensile strength ( fracture strain )
C    props(2)     Xc  X fiber compressive strength ( fracture strain )
C    props(3)     Yt  Y and Z matrix tensile strength ( fracture strain )
C    props(4)     Yc  Y and Z matrix compressive strength ( fracture strain )
C    props(5)     S12  1 and 2 shear strength ( fracture strain )
C    props(6)     S13  1 and 3 shear strength ( fracture strain )
C    props(7)     S23  2 and 3 shear strength ( fracture strain )
c    props(8)     E11   elastic modulus E11
c    props(9)     E22   elastic modulus E22
c    props(10)    E33   elastic modulus E33 
c    props(11)    V12   Poisson's ratio v12
c    props(12)    V13   Poisson's ratio v13 
c    props(13)    V23   Poisson's ratio v23
c    props(14)    G12   shear modulus G12
c    props(15)    G13   shear modulus G13 
c    props(16)    G23   shear modulus G23

C-----------------------Material strength parameters----------     
      Xteqs = props(1)   
      Xceqs = props(2)   
      Yteqs = props(3)   
      Yceqs = props(4)   
      S12eqs = props(5)   
      S13eqs = props(6)   
      S23eqs = props(7)   	  
C---------------------- Material elastic parameters---------------     
      E11qs = props(8)   
      E22qs = props(9)   
      E33qs = props(10)   
      V12 = props(11)   
      V13 = props(12)   
      V23 = props(13)   
      G12qs = props(14)   
      G13qs = props(15)   
      G23qs = props(16)  
C C--------------------Compute strength of strain---------       
C C     Xte = Xt / E11     
C C      Xce = Xc / E11     
C C      Yte = Yt / E22     
C C      Yce = Yc / E22     
C C      S12e = S12 / G12     
C C      S13e = S13 / G13     
C C      S23e = S23 / G23  
C c-----------compute v21、 v31、v32---------------------------        
C C      v21 = ( v12 / E11 ) * E22       
C C     v31 = ( v13 / E11 ) * E33        
C C      v32 = ( v23 / E22 ) * E33      
C------------- Update strain component -----------------------              
      DO i=1,nblock    
      stateNew(i,1) = stateold(i,1) + StrainInc(i,1)         
      stateNew(i,2) = stateold(i,2) + StrainInc(i,2)         
      stateNew(i,3) = stateold(i,3) + StrainInc(i,3)         
      stateNew(i,4) = stateold(i,4) + StrainInc(i,4)         
      stateNew(i,5) = stateold(i,5) + StrainInc(i,5)         
      stateNew(i,6) = stateold(i,6) + StrainInc(i,6)  
c------------------- Damage coefficient----------------------        
      stateNew(i,7) = stateOld(i,7)       
      stateNew(i,8) = stateOld(i,8)        
      stateNew(i,9) = stateOld(i,9)
      stateNew(i,10) = stateOld(i,10)        
      stateNew(i,11) = stateOld(i,11)        
      stateNew(i,12) = stateOld(i,12)        
      stateNew(i,13) = stateOld(i,13)        
      stateNew(i,14) = stateOld(i,14)        
      stateNew(i,15) = stateOld(i,15) 
c------------------- Damage factor variables----------------------        
      stateNew(i,16) = stateOld(i,16)       
      stateNew(i,17) = stateOld(i,17)        
      stateNew(i,18) = stateOld(i,18)
      stateNew(i,19) = stateOld(i,19)        
      stateNew(i,20) = stateOld(i,20)
      stateNew(i,21) = stateOld(i,21)
      stateNew(i,22) = stateOld(i,22)

C C----The shear strain components in user subroutine VUMAT --
C C----are stored as tensor components---
C C--------------------Compute quasi-static strength of strain---------       
C c----      Xteqs = Xtqs / E11qs     
C c----      Xceqs = Xcqs / E11qs     
C c----      Yteqs = Ytqs / E22qs    
C c----      Yceqs = Ycqs / E22qs     
C c----      S12eqs = S12qs / G12qs     
C c----      S13eqs = S13qs / G13qs     
C c----      S23eqs = S23qs / G23qs
C       Xteqs = 0.02148     
C       Xceqs = 1.773 * 0.01     
C       Yteqs = 0.508 * 0.01   
C       Yceqs = 1.09 * 0.01     
C       S12eqs = 3.854 *0.01     
C       S13eqs = 3.854 *0.01      
C       S23eqs = 1.297 *0.01  
c----------- do not consider strain rate, the material parameters is equal to the quasi-static parameter ----------------
      XE11 = E11qs   
      XE22 = E22qs
      XE33 = E33qs    
      XG12 = G12qs  
      XG13 = G13qs   
      XG23 = G23qs 
	   
	  Xte = Xteqs 
      Xce = Xceqs 
      Yte = Yteqs  
      Yce = Yceqs   
      S12e = S12eqs 
      S13e = S13eqs
      S23e = S23eqs
c-----------compute v21、 v31、v32---------------------------        
      v21 = ( v12 / XE11 ) * XE22       
      v31 = ( v13 / XE11 ) * XE33        
      v32 = ( v23 / XE22 ) * XE33  

c-----------Material elastic parameters poisson ---------------------------   
      XV12 = V12   
      XV13 = V13  
      XV23 = V23 
      
      XV21 = V21   
      XV31 = V31   
      XV32 = V32       
c---- sr23 -------- 
c--- if there are not the out-of-plane shear parameters , you can use the following code:
C       XG23 = XE22/2*(1+XV23) 
C       S23 = Yc / 2
C       s23e = S23eqs         
C----------- Set primary damage factor for 0. 0 ------------- 
c----eft for fiber tensile damage       
      eft = 0.0  
c----efc for fiber compression damage       
      efc = 0.0 
c----emt for Y and Z direction tensile damage        
      emt = 0.0 
c----emc for Y and Z direction compression damage      
      emc = 0.0
c----ems for Y and Z direction Share damage      
      ems12 = 0.0  
c----ems for Y and Z direction Share damage      
      ems = 0.0  
c------------------Degrade material elastic parameter---------------- 
c--------------Fiber tension----------    
      if ( stateNew(i,7).EQ.1.0 ) then         
      XE11 = XE11 * 0.01
      XE22 = XE22 * 1  
      XE33 = XE22 * 1       
      XG12 = XG12 * 0.01         
      XG23 = XG23 * 1 
      XG13 = XG13 * 0.01       
      XV12 = XV12 * 1       
      XV23 = XV23 * 1       
      XV13 = XV13 * 1              
      end if

C-------------fiber compress---------      
      if ( stateNew(i,8).EQ.1.0 ) then         
      XE11 = XE11 * 0.01
      XE22 = XE22 * 1  
      XE33 = XE22 * 1       
      XG12 = XG12 * 0.01         
      XG23 = XG23 * 1 
      XG13 = XG13 * 0.01       
      XV12 = XV12 * 1       
      XV23 = XV23 * 1       
      XV13 = XV13 * 1        
      end if 
c------------matrix tension---------            
      if ( stateNew(i,10).EQ.1.0 ) then          
      XE11 = XE11 * 1
      XE22 = XE22 * 0.01  
      XE33 = XE22 * 0.01      
      XG12 = XG12 * 0.01
      XG23 = XG23 * 0.01 
      XG13 = XG13 * 0.01       
      XV12 = XV12 * 1       
      XV23 = XV23 * 1       
      XV13 = XV13 * 1             
      end if 
c------------matrix compression------            
      if ( stateNew(i,11).EQ.1.0 ) then          
      XE11 = XE11 * 1
      XE22 = XE22 * 0.01  
      XE33 = XE22 * 0.01      
      XG12 = XG12 * 0.01
      XG23 = XG23 * 0.01 
      XG13 = XG13 * 0.01       
      XV12 = XV12 * 1       
      XV23 = XV23 * 1       
      XV13 = XV13 * 1              
      end if  
c------------YZ Shear compress------              
      if ( stateNew(i,13).EQ.1.0 ) then          
      XE11 = XE11 * 1
      XE22 = XE22 * 1  
      XE33 = XE22 * 1       
      XG12 = XG12 * 1         
      XG23 = XG23 * 0.01 
      XG13 = XG13 * 1       
      XV12 = XV12 * 1       
      XV23 = XV23 * 1       
      XV13 = XV13 * 1            
      end if
c------------XY Shear compress------              
      if ( stateNew(i,22).EQ.1.0 ) then          
      XE11 = XE11 * 1
      XE22 = XE22 * 1  
      XE33 = XE22 * 1       
      XG12 = XG12 * 0.01         
      XG23 = XG23 * 1 
      XG13 = XG13 * 0.01       
      XV12 = XV12 * 1       
      XV23 = XV23 * 1       
      XV13 = XV13 * 1            
      end if        
C---------------Calculate stiffness matrix- -----------------------------     
      fact = 1.0-XV12*XV21-XV23*XV32-XV31*XV13-2.0*XV21*XV32*XV13   
      factor = 1.0 / fact        
      C(1,1) = xe11 * ( 1.0 - xV23*xV32 ) * factor      
      C(1,2) = xe22 * ( xV12 + xV32*xV13 ) * factor        
      C(1,3) = xe33 * ( xV13 + xV12*xV23 ) * factor        
      C(2,1) = C(1,2)        
      C(2,2) = xe22 * ( 1.0 - xV13*xV31 ) * factor        
      C(2,3) = xe33 * ( xV23 + xV21*xV13 ) * factor        
      C(3,1) = C(1,3)        
      C(3,2) = C(2,3)        
      C(3,3) = xe33 * ( 1.0 - xV12*xV21 ) * factor        
      C(4,4) = xg12        
      C(5,5) = xg23        
      C(6,6) = xg13 
C--------------------- Calculate stress-------------------------        
      stressNew(i,1)=C(1,1)*stateNew(i,1)+C(1,2)*stateNew(i,2)+C(1,3)*stateNew(i,3)         
      stressNew(i,2)=C(2,1)*stateNew(i,1)+C(2,2)*stateNew(i,2)+C(2,3)*stateNew(i,3)        
      stressNew(i,3)=C(3,1)*stateNew(i,1)+C(3,2)*stateNew(i,2)+C(3,3)*stateNew(i,3)        
      stressNew(i,4)=C(4,4)*2.0*stateNew(i,4)        
      stressNew(i,5)=C(5,5)*2.0*stateNew(i,5)        
      stressNew(i,6)=C(6,6)*2.0*stateNew(i,6)  
c---engineering strain=2*strain tensor, so stateNew(i,j) is strain tensor-------
C---------------------------------------------------------------------------------------  
C---------------- Calculate X Direction Damage (fiber damage)------------------ 
      if (stateNew(i,9)  .LT. 1.0) then          
      if ( stateNew(i,1)  .GT. 0.0) then             
      eft  = (stateNew(i,1) / Xte)**2.0+k*(stateNew(i,4)/S12e)**2.0+k*(stateNew(i,6)/S13e)**2.0     
      else             
      efc  = (stateNew(i,1) / Xce)**2.0     
      end if     
      end if  
C------------ Calculate Y and Z Direction Damage (matrix damage)—
C------e2+e3>0, Matrix tensile ------------- 
C------e2+e3<0, Maxtix compression-------          
      if (stateNew(i,12)  .LT. 1.0)    then                     
      if ( (stateNew(i,2)+stateNew(i,3)) .GT. 0.0) then
      emt = ((stateNew(i,2)+stateNew(i,3))/Yte)**2.0+(stateNew(i,4)**2.0)/(S12e**2.0)
     &+((stateNew(i,6)**2.0))/(S13e**2.0)+(stateNew(i,5)**2.0       
     &-stateNew(i,2)*stateNew(i,3))/(S23e**2.0)   
      ems =(stateNew(i,5)/S23e )**2.0+(stateNew(i,6)/S13e )**2.0
      ems12= (stateNew(i,4)/s12e)**2     
      else               
      emc  =((stateNew(i,2)+stateNew(i,3))/Yce)**2.0 
c	  emc  =((stateNew(i,2))/Yce)**2.0
      ems =(stateNew(i,5)/S23e )**2.0+(stateNew(i,6)/S13e )**2.0
      ems12= (stateNew(i,4)/s12e)**2       
      end if 
      end if  
C------------ Calculate in-plane and out-of-plane shear damage )—      
C       ems =(stateNew(i,5)/S23e )**2.0+(stateNew(i,6)/S13e )**2.0
C       ems12= (stateNew(i,4)/s12e)**2           
c-------------------------------------------------------------  
c----------- Five damage factor 
c-------------------------------------------------------------     
      stateNew(i,16) = eft      
      stateNew(i,17) = efc        
      stateNew(i,18) = emt
      stateNew(i,19) = emc       
      stateNew(i,20) = ems
      stateNew(i,21) = ems12
c-------------------------------------------------------------  
c----------- Five failure modes states 
c-------------------------------------------------------------        
      if (eft.GE.1) then          
      stateNew(i,7)  = 1.0           
      stateNew(i,9) = 1.0           
      stateNew(i,14) = 1.0        
      end if                

      if (efc.GE.1) then           
      stateNew(i,8) = 1.0           
      stateNew(i,9) = 1.0           
      stateNew(i,14) = 1.0        
      end if               

      if (emt.GE.1) then           
      stateNew(i,10) = 1.0           
      stateNew(i,12) = 1.0          
      stateNew(i,14) = 1.0        
      end if                

      if (emc.GE.1) then           
      stateNew(i,11) = 1.0          
      stateNew(i,12) = 1.0           
      stateNew(i,14) = 1.0        
      end if               

      if (ems.GE.1) then          
      stateNew(i,13) = 1.0           
      stateNew(i,14) = 1.0        
      end if        

      if (ems12.GE.1) then          
      stateNew(i,22) = 1.0                  
      end if       
c--------------Elements Delete-----------              
      if ((stateNew(i,9).GE.1.0) .AND. (stateNew(i,12).GE.1.0)) then       
      stateNew(i,15) = 0.0        
      end if                

c      if (stateNew(i,9).GE.1.0) then       
c      stateNew(i,15) = 0.0        
c      end if   

c      if (stateNew(i,12).GE.1.0) then       
c      stateNew(i,15) = 0.0        
c      end if            

      if ( stateNew(i,13) .GE.1.0) then        
      stateNew(i,15) = 0.0        
      end if  
      
      if ( stateNew(i,22) .GE.1.0) then        
      stateNew(i,15) = 0.0        
      end if  


c            
      END DO
      return
      end







