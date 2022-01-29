for p=1:18;
% sparsitytolernece 1e-9
rtf=jsonread(['tessar-zemax-poly' num2str(p) '-raytransfer.json']);
c=rtf.polynomials.poly.coeff;
nbCoeffSparse(p)=numel(c);
% No sparsity tolerance sparse
rtf=jsonread(['tessar-notsparse-zemax-poly' num2str(p) '-raytransfer.json']);
c=rtf.polynomials.poly.coeff;
nbCoeffNotSparse(p)=numel(c);


end