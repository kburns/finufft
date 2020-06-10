function [f ier] = finufft2d1(x,y,c,isign,eps,ms,mt,o)
% FINUFFT2D1
%
% [f ier] = finufft2d1(x,y,c,isign,eps,ms,mt)
% [f ier] = finufft2d1(x,y,c,isign,eps,ms,mt,opts)
%
% Type-1 2D complex nonuniform FFT.
%
%                   nj
%     f[k1,k2] =   SUM  c[j] exp(+-i (k1 x[j] + k2 y[j]))
%                  j=1
%
%     for -ms/2 <= k1 <= (ms-1)/2,  -mt/2 <= k2 <= (mt-1)/2.
%
%   Inputs:
%     x,y   locations of NU sources on the square [-3pi,3pi]^2, each length nj
%     c     size-nj complex array of source strengths
%     isign  if >=0, uses + sign in exponential, otherwise - sign.
%     eps     precision requested (>1e-16)
%     ms,mt  number of Fourier modes requested in x & y; each may be even or odd
%           in either case the mode range is integers lying in [-m/2, (m-1)/2]
%     opts.debug: 0 (silent, default), 1 (timing breakdown), 2 (debug info).
%     opts.spread_sort: 0 (don't sort NU pts), 1 (do), 2 (auto, default)
%     opts.fftw: 0 (use FFTW_ESTIMATE, default), 1 (use FFTW_MEASURE)
%     opts.modeord: 0 (CMCL increasing mode ordering, default), 1 (FFT ordering)
%     opts.chkbnds: 0 (don't check NU points valid), 1 (do, default).
%     opts.upsampfac: either 2.0 (default), or 1.25 (low RAM, smaller FFT size)
%   Outputs:
%     f     size (ms*mt) double complex array of Fourier transform values
%           (ordering given by opts.modeord in each dimension, ms fast, mt slow)
%     ier - 0 if success, else:
%           1 : eps too small
%           2 : size of arrays to malloc exceed MAX_NF
%           other codes: as returned by cnufftspread
%
% All available threads are used; control how many with maxNumCompThreads

if nargin<8, o.dummy=1; end
nj=numel(x);
n_transf = round(numel(c)/numel(x));
if numel(y)~=nj, error('y must have the same number of elements as x'); end
if n_transf*nj~=numel(c), error('the number of elements of c must be divisible by the number of elements of x'); end
p = finufft_plan(1,[ms;mt],isign,n_transf,eps,o);
p.finufft_setpts(x,y,[],[],[],[]);
[f,ier] = p.finufft_exec(c);
