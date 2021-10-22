!I realized this morning that the B matrix I gave you may have some bad properties since it is statistically derived rather than analytical.
!To be appropriate, it must be positive definite and its condition number (ratio of largest to smallest eigenvalue) should not be too large. So, 
!perhaps constructing an anlytical one would be better. I have software that you can follow as an example - just a few lines....

! CODE TO BUILD UP THE COVIANCE MATRIX

program cov_mat

IMPLICIT NONE

REAL, PARAMETER :: R_gas = 287.0,  T_ref = 270.0, Grav = 9.8, pi = 3.1415926535, c_p = 1005.0
INTEGER, PARAMETER :: nlevels = 72

INTEGER :: i, j, k

!STANDARD DEVIATION DATA
REAL :: Plev_sd(nlevels), Ps_sd(nlevels), T_sd(nlevels), TH_sd(nlevels), Q_sd(nlevels), U_sd(nlevels), V_sd(nlevels)

REAL :: sigma(2*nlevels), plevels(nlevels), plevels2(2*nlevels)

REAL :: xfac, x, corr
INTEGER :: v_lengths

REAL :: cov(2*nlevels,2*nlevels)

 CHARACTER*20 :: func_name, file_name

!======================================
!LOAD IN STANDARD DEVIATION DATA
open(13,file='errorvariance72')

DO i = 1,nlevels
   read (13,'(f9.3,f8.3,f7.3,f12.8,2f8.2)') plevels(i), Ps_sd(i), T_sd(i), Q_sd(i), U_sd(i), V_sd(i)

endDO
 close(13)

!Ps_sd = Ps_sd*0.01
!Plev_sd = Plev_sd*0.01

TH_sd = T_sd/(((plevels+Ps_sd)/100000.0)**(R_gas/c_p))

!======================================


sigma(1:nlevels) = TH_sd
sigma(nlevels+1:2*nlevels) = Q_sd

plevels2(1:nlevels) = plevels
plevels2(nlevels+1:2*nlevels) = plevels


v_lengths= 550 !T
!v_lengths= 550 !q
!v_lengths= 900 !u
!v_lengths= 900 !v

! Fill symmetric covariance matrix assuming a vertical correlation structure that is a gaussian-shaped function in terms of vertical separation x.

! xfac changes p to z and uses v_lengths to define the correlation length.

       xfac=-0.5*(R_gas*T_ref/(Grav*v_lengths))**2
       do k=1,2*nlevels
         do j=k,2*nlevels
           x=log(plevels2(k)/plevels2(j))
           IF ((k .LE. 72 .AND. j .LE. 72) .OR. (k .GT. 72 .AND. j .GT. 72)) THEN
 	      corr = exp(xfac*x*x)
           ELSE
              corr = 0
           endIF
           cov(k,j)=sigma(k)*sigma(j)*corr
           cov(j,k)=cov(k,j)
         enddo
       enddo




!These are rough tropospheric values above the PBL but you can use them everywhere for your purpose. make sure your B is invertable.

!The plevels and sigma are the pk and stdv in my earlier code.

!dan; note that real background error correlations of T are not really 
!gaussian but have negative lobes.  i don't know what that means for your 
!toy model.

!The covariances are made by taking the correlations and multiplying by the 2 appropriate standard deviations.  Note that this has no 
!correlations between fields, only between different levels for the same field. (Thus you multiply by the 2 stdvs corresponding to the 2 levels).
!Also note that small values can be reset to 0.

!You still need an R matrix, but we can construct one from this B. If H is your Jacobian, and HT its transpose, you take the diagonal of  X 
!= H B HT and multiply it by 4. For values corresponding to above say 100 mb, multiply the largest tropospheric diagonal value by 100.
!That diagonal construct may be something to start from.


WRITE(file_name,'(a,a)') 'covariance_matrix','.m'
WRITE(func_name,'(a)') 'B'
 call twodimdump(cov,2*nlevels,2*nlevels,file_name,func_name)


end program

