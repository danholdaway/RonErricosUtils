!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||!
!===============================================================================!
!                                   SUBROUINES                                  !
!===============================================================================!
!|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||!



!===============================================================================!
!==================================  GRID DUMP =================================!
!===============================================================================!
subroutine griddump(nx,ny,nz)

! Subroutine to output generic vector that can be read by Matlab

IMPLICIT NONE

INTEGER :: nx, ny, nz
 CHARACTER*20 :: filename

WRITE(filename,'(a,a)') 'grid_data','.m'

OPEN(13,file=filename,form='formatted')

WRITE(13,*) 'Ni = ', Nx, ';'
WRITE(13,*) 'Nj = ', Ny, ';'
WRITE(13,*) 'Nk = ', Nz, ';'
WRITE(13,*) 'lon = 0:360/(',nx,'):360-(360/',nx,') ;'
WRITE(13,*) 'lat = 0:180/(',ny,'):180-(180/',ny,') ;'
WRITE(13,*) 'lon = lon-180 ;'
WRITE(13,*) 'lat = lat-90 ;'

 close(13)

end subroutine griddump
!===============================================================================!


!===============================================================================!
!================================  ONE DIM DUMP ================================!
!===============================================================================!
subroutine onedimdump(mat,nx,filename,funcname)

! Subroutine to output generic vector that can be read by Matlab

IMPLICIT NONE

INTEGER :: nx
INTEGER :: iii
REAL :: mat(nx)
 CHARACTER*20 :: filename
 CHARACTER*20 :: funcname

OPEN(13,file=filename,form='formatted')

WRITE(13,*) funcname,' = ['
do iii=1, Nx
WRITE(13,*) mat(iii),';...'
enddo
WRITE(13,*) '];'
 close(13)

end subroutine onedimdump
!===============================================================================!


!===============================================================================!
!================================  TWO DIM DUMP ================================!
!===============================================================================!
subroutine twodimdump(mat,nx,ny,filename,funcname)

! Subroutine to output generic 2D matrix that can be read by Matlab as a vector
! Output as a vector for improved compatibility between compilers.
! Extra algorithm required to turn into 2D matrix in Matlab

IMPLICIT NONE

INTEGER :: nx, ny
INTEGER :: iii, jjj
REAL :: mat(nx,ny)
 CHARACTER*20 :: filename
 CHARACTER*20 :: funcname
 CHARACTER*20 :: funcname_temp

WRITE(funcname_temp,'(a)') 'A'

OPEN(13,file=filename,form='formatted')

WRITE(13,*) funcname_temp,' = ['
do jjj=1, Ny
do iii=1, Nx
WRITE(13,*) mat(iii,jjj),';...'
enddo
enddo
WRITE(13,*) '];'
WRITE(13,*) funcname,'=zeros(',nx,',',ny,');'
WRITE(13,*) 'for k = 1:',ny
WRITE(13,*) funcname,'(:,k) = ',funcname_temp,'...'
WRITE(13,*) '(',nx,'*k-...'
WRITE(13,*) nx,'+1:',nx,'*k);'
WRITE(13,*) 'end'
WRITE(13,*) 'clear ',funcname_temp, 'k'
 close(13)
 


end subroutine twodimdump
!===============================================================================!

!===============================================================================!
!============================  TWO DIM DUMP INTEGER ============================!
!===============================================================================!
subroutine twodimdumpint(mat,nx,ny,filename,funcname)

! Subroutine to output generic 2D matrix that can be read by Matlab as a vector
! Output as a vector for improved compatibility between compilers.
! Extra algorithm required to turn into 2D matrix in Matlab

IMPLICIT NONE

INTEGER :: nx, ny
INTEGER :: iii, jjj
INTEGER :: mat(nx,ny)
 CHARACTER*20 :: filename
 CHARACTER*20 :: funcname
 CHARACTER*20 :: funcname_temp

WRITE(funcname_temp,'(a)') 'A'

OPEN(13,file=filename,form='formatted')

WRITE(13,*) funcname_temp,' = ['
do jjj=1, Ny
do iii=1, Nx
WRITE(13,*) mat(iii,jjj),';...'
enddo
enddo
WRITE(13,*) '];'
WRITE(13,*) funcname,'=zeros(',nx,',',ny,');'
WRITE(13,*) 'for k = 1:',ny
WRITE(13,*) funcname,'(:,k) = ',funcname_temp,'...'
WRITE(13,*) '(',nx,'*k-...'
WRITE(13,*) nx,'+1:',nx,'*k);'
WRITE(13,*) 'end'
WRITE(13,*) 'clear ',funcname_temp, 'k'
 close(13)
 


end subroutine twodimdumpint
!===============================================================================!
