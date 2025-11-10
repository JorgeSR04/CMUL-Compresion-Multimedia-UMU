function [x,hexp,hteor] = SimulaH(n,P);

x = GenSeqDDP(n,P);
FREQ = Freq256(x);
Pexp = FREQ/n;

hexp = Entro(Pexp);
hteor = Entro(P);

