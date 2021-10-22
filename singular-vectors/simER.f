
Date: Fri, 14 May 1999 11:40:31 -0600 (MDT)
From: Martin Ehrendorfer <ehren@cgd.ucar.edu>
Mime-Version: 1.0

#QSUB -eo -nr -q prem  -lM 10.0Mw -lm 9.5Mw -lT 03:00:00 -lt 02:55:00
#
#***************************************************************
#  script to do similarity index for 
#  one E-norm SV (set A) and one R-norm SV (set B) in the E-norm
#***************************************************************
#
#  to compute projections of different SV spaces 
#  martin ehrendorfer 19 august 96  
#
#  modified at NCAR 1/22/97
#  modified at NCAR 5/10/99 
#  this code is designed to compare to sets of TE SVs 
#  in the TE norm. The way it is done is using the 
#  dimensionless vectors z_k where v_k = N^{-1/2} z_k
#  The standard Euclidean product of the z_k gives TE. 
#  Comparing 2 sets of SVs is done by taking the mutual 
#  projections of the z_k. This can be immediately 
#  extended to the R-norm z_k. 
#
#  To modify and run this search for 'change'
#
cd $TMPDIR
csh -x << 'JOBEND' >& log
setenv NCPUS 1
#
# change
set cgdname = 'spc1vs3_er'
#
rm spc.* 
ja
# 
cat << 'EOFD' > spc.f
c
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c 
c
	program space
c
c********************************************************************
c  	code to compute similarity indices of two SV-spaces 
c	this follows the two articles by Buizza 1994 QJ
c	the similarity index is defined as the squared scalar product
c	martin ehrendorfer, 15 august 1996
c	m.e. 1/22/1997, 2/12/97, 
c       modified for correct orthonormalization, m.e., 4/3/97
c       do the orthonormalization with mod Gram/schmidt me 4/7/97
c       modified 5/11/99
c********************************************************************
c
c change next 2 lines
	parameter (n=79354,ma=20,mb=20)     ! n dimension of vectors, m number of SVs
	parameter (na=79354,na1=104294,nb=104294)  ! the actual dimensions (moisture) 
	parameter (nap2=na+2,na1p2=na1+2,nbp2=nb+2)
	real a (na) , b (nb)        ! the actual vectors from the mass-store
        real a1 (na1)               ! vector to contain N^{1/2}
	real xm (ma,mb)             ! the matrix of projections
        real xa (n,ma) , xb (n,mb)  ! matrices to contain hat vectors
        real za (ma,ma), zb (mb,mb) ! to check orthogonality
        real xta (ma,n) ,xtb (mb,n) ! transposed matrices
        real simin (ma)             ! vector of similarity indices
c
	character*120 mssa, mssa1 , mssb   !  the names of the mass-store files
c
c2345678901234567890123456789012345678901234567890123456789012345678901234567890
c
c change next few lines for mass store names
c
c exp_1
        mssa = 
     1'/RAEDER/MAMS/EXPL/H48-72/LANC/IS1/I1-199/v.dat.1'
        mssa1 = 
     1'/RAEDER/MAMS/EXPL/H48-72/LANC/IS1/I1-199/vdim.dat.1'
c
c exp_2
c        mssb = 
c     1'/RAEDER/MAMS/EXPL/H24-48/LANC/MSTTLM/IS1/I0-199/V1-20/vdim.dat.1'
c
c exp_3
        mssb =
     1'/RAEDER/MAMS/EXPL/H48-72/LANC/IS4/I0-199/vdim.dat.1'
c
c
	open (unit=22,file='xvector',form='unformatted',
     1      access='direct',recl=nap2*8)  !  z-vectors from experiment A
	open (unit=24,file='x1vector',form='unformatted',
     1      access='direct',recl=na1p2*8)  !  v-vectors from experiment A
	open (unit=23,file='yvector',form='unformatted',
     1      access='direct',recl=nbp2*8)  !  v-vectors from experiment B
c
	write (21,530) mssa, mssa1, mssb
530	format(/2x,'experiment A   0 xvector '/2x,a80//
     1         /2x,'experiment A1  0 x1vector'/2x,a80//              
     1         /2x,'experiment B   0 yvector '/2x,a80//)
c
c	section to read vectors - need to read the dimensionless vectors
c  	for the following reason:  
c
c	y ... vectors with dimension: y^T A^T A y = 1 (A for total energy)
c       z ... dimensionless vectors: z = Ay: z^T z = 1 (Euclidean)
c	we want to compute y^T A^T A y = 1 which is the same 
c	as z^T z = 1 by z = Ay. 
c
c--- exp A ... read and make orthogonal (if necessary)
c
	do 100 i = 1 , ma         !  loop over the SVs from experiment A
	irec = i
	read (22,rec=irec) evx,bndevx,(a(k),k=1,na) 
	write (21,540) i,evx,bndevx
 540	format (2x,'vector read ...',i5,5(1pe15.7))
        do 110 ii = 1 , n
        xa (ii,i) = a (ii)        !  put vector i into t-th column
 110    continue

        if (i.eq.1) then          !  read first v-vector to get E-wgts
	read (24,rec=irec) evx,bndevx,(a1(k),k=1,na1) 
        write (21,540) i,evx,bndevx
        do 115 ii = 1 , na
        a1 (ii) = a (ii) / a1 (ii)  !  z/v = N^{1/2} (dry E-wgts)
 115    continue
c       call matprt (a1,1,na,'energy weights',21)
        endif 

 100    continue
c
	call mgs    (xa,n,ma,za)          ! modified GS on xa
	call matprt (za,ma,ma,'matrix r in QR decomp. A ... ',21)
        call matran (xa,n,ma,xta)         ! transpose xa -> xta
        call matmul (xta,xa,za,ma,n,ma)   ! orthonormality check
        call matprt (za,ma,ma,'orthonormality of exp. A',21)
c
c--- exp B ... read and make orthogonal (if necessary)
c
	do 120 i = 1 , mb         !  loop over the SVs from experiment B
	irec = i 
	read (23,rec=irec) evy,bndevy,(b(k),k=1,nb) 
	write (21,540) i,evy,bndevy
        do 130 ii = 1 , n
        b (ii) = a1 (ii) * b (ii) !  make z = N^{1/2} v
        xb (ii,i) = b (ii)        !  put vector i into t-th column
 130    continue
 120    continue
c
	call mgs    (xb,n,mb,zb)          ! modified GS on xa
	call matprt (zb,mb,mb,'matrix r in QR decomp. B ... ',21)	
        call matran (xb,n,mb,xtb)         ! transpose xb -> xtb
        call matmul (xtb,xb,zb,mb,n,mb)   ! orthonormality check
        call matprt (zb,mb,mb,'orthonormality of exp. B',21)
c
c compute matrix of projections
c
        call matmul (xta,xb,xm,ma,n,mb)   ! the matrix of projections
        do 140 i = 1 , ma
        do 150 j = 1 , mb
        xm (i,j) = xm (i,j) * xm (i,j) 
150     continue
140     continue
c
	call matprt (xm,ma,mb,
     1  'squared projcts; row i = vector i of A on all of B',21)
c       'the matrix of projections',21)  ! print proj's
c
c	compute the similarity index (as function of k SVs compared)
c
        do 160 i  = 1 , ma
	store = 0.0
	do 170 ii = 1 , i
	do 180 jj = 1 , i
        store = store + xm (ii,jj)  
180	continue
170     continue
        simin (i) = store / float (i)
c	simin = simin / float (m)              !  this is ok: divide by m not m^2
c	simin = simin / sqrt (float (ma*mb))   !  this is ok: divide by m not m^2
        write (21,550) i,simin(i) 
550     format (2x,'similarity index for SVs, k=',i7,1pe15.7)
160     continue
c
c	write (21,500) simin
c500	format(/2x,'the similarity index here is',1pe15.7/)
c
	stop
	end
c
c
c
c
c
	subroutine mgs (a,m,n,r)
c
c  modified Gram Schmidt, Strang, p. 389, m.e. 4/5/97
c
	real a (m,n) , r (n,n) !  a with m rows and n columns
c	
	do 10 k = 1 , n
c	
	s = 0.0
	do 20 i = 1 , m
        s = s + a (i,k) * a (i,k)
20      continue
	r (k,k) = sqrt ( s )
c
	do 30 i = 1 , m
        a (i,k) = a (i,k) / r (k,k)
30      continue
c	
	do 40 j = k + 1 , n
c	
	s = 0.0
	do 50 i = 1 , m
        s = s + a (i,k) * a (i,j)
50      continue
	r (k,j) = s
c
        do 60 i = 1 , m
        a (i,j) = a (i,j) - a (i,k) * r (k,j)
60      continue
c
40      continue
10      continue
c
	return
	end
c
c
c
C
        SUBROUTINE MATPRT (A,NA,MA,COMMENT,LUNIT)
C===========================================================
C
c       by m.e.
c
        REAL A (NA,MA)
        INTEGER LUNIT
        CHARACTER*(*) COMMENT
C
        WRITE (LUNIT,'(/2X,A)') COMMENT
        DO 10 I = 1 , NA
10      WRITE (LUNIT,100) I , ( A (I,J) , J = 1 , MA )
c100    FORMAT ( 2X,I5,5(1PE13.5) / 200 ( 7X,5(1PE13.5)/ ) )
100     FORMAT ( 1X,I2,8(f8.4) / 200 ( 3X,8(f8.4)/ ) )
C
C
        RETURN
        END
C
c
c
c
	subroutine matran (a,n,m,b)
	real a (n,m), b (m,n)
	do 10 i = 1 , m
        do 20 j = 1 , n
	b (i,j) = a (j,i)
 20	continue
 10     continue
	return
	end
c
	subroutine matmul (a,b,c,n,m,k)
	real a (n,m) , b (m,k) , c (n,k) 
	do 10 i = 1 , n
	do 20 j = 1 , k
        c (i,j) = 0.0
	do 30 l = 1 , m 
        c (i,j) = c (i,j) + a (i,l) * b (l,j)
 30     continue
 20     continue
 10     continue
        return
	end
c	
c
c
c 
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c

'EOFD'

#change
acquire /RAEDER/MAMS/EXPL/H48-72/LANC/IS1/I1-199/v.dat.1 0 xvector
acquire /RAEDER/MAMS/EXPL/H48-72/LANC/IS1/I1-199/vdim.dat.1 0 x1vector
#acquire /EHREN/mm7/run1/n1/vector.dat.1 0 xvector
#cp xvector yvector
#change
acquire /RAEDER/MAMS/EXPL/H48-72/LANC/IS4/I0-199/vdim.dat.1 0 yvector 
#acquire /RAEDER/MAMS/EXPL/H24-48/LANC/MSTTLM/IS1/I0-199/V1-20/vdim.dat.1 0 yvector
#acquire /RAEDER/MAMS/EXDHI/LANC/MST/H24-48/DRYTLM/IS4/I0-199/V1-20/vdim.dat.1 0 yvector 
#acquire /EHREN/mm7/run1/n4/vector.dat.1 0 yvector

assign -a xvector  fort.22
assign -a x1vector fort.24
assign -a yvector  fort.23
assign -a spcout   fort.21

f90raed spc.f llu "-evi -r2" nolib exec
#cftron spc.f iz gks adj,ncarm,ncaro exec noP
ls -l
 
#dispose moutput mm6/run1/n1/tlm.1.tseries copy 365 tseries
#dispose xinit   mm6/run1/n1/tlm.1.xinit   copy 365 xinit

rcp spc.lst    redmtn.cgd.ucar.edu:/data/ehren/${cgdname}.lst
rcp spcout   redmtn.cgd.ucar.edu:/data/ehren/${cgdname}.out

ja -st
rcp log  redmtn.cgd.ucar.edu:/data/ehren/${cgdname}.log
exit
 
'JOBEND'

#rcp log ra.cgd.ucar.edu:/u2/ehren/cray/mm4/svs/proj/${cgdname}.log

exit



