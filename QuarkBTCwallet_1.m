function [addres,secret,pub_key,pr_key]=QuarkBTCwallet(secret,addres)
%
%   QuarkBTCwallet
%
%   QuarkBTCwallet(secret)
%
%   [addres,secret,pub_key,pr_key]=QuarkBTCwallet
%
% QuarkBTCwallet is an improvement of function BTCwallet. It performs the
% same operations, but provides a different final output. This output 
% consists of three wallets each one containing 2/3 of the secret key
%
% You can generate completely the three wallets by prompting:
% 
%   QuarkBTCwallet 
%
% If, instead, you prompt:
% 
%   QuarkBTCwallet(secret_key_string_in_base58)
%
% then you can obtain the three "quarkwallets" of any other cold wallet.
% If you prefer, you can also promp (with obvious result):
%
%   QuarkBTCwallet(secret_key_string_in_base58, address_string_in_base58)
%
% The latter method is not recommended as it doubles the risk of a typing 
% error. Instead, try to enter only the secret key and check if the 
% calculated associated address matches yours.

noproblemo=1;
% Deciding if creates a wallet or plays with an existent one
if nargin==0;
 [addres,secret,pub_key,pr_key]=BTCwallet; close(gcf);
elseif nargin==1;
  disp('Wait just about 10 seconds, and your three quark wallets will be ready')
  % Changing the secret to hexadecimal and taking out control numbers
  pr_key=hex2b58(secret,-1);pr_key=pr_key(3:end-8);
  if (length(pr_key)>64)*(strcmp(pr_key(end-1:end),'01'));
        pr_key=pr_key(1:end-2);
  else;clc;disp(' ');disp('A problem of this two has ocurred, or (i) you have introduced spaces in the private key');
       disp('or (ii) you use non-compressed keys. It is my fault.  This version only works for compressed');noproblemo=0;
  end
  if noproblemo  
     % Applying Elliptic curve cryptography (ECDSA) to obtain public key (file secp256k1.m)
     [px,py]=secp256k1(pr_key);
     % Obtaining the address (local function copied from BTCwallwt.m)
     [addres,~]=BTCaddress(px,py,1); %compressed=1;  
  end
elseif nargin==2;% Just break in three without any verification in the nex step, just an advice
   clc;disp(' ');disp(' ');disp(' ');disp(' ');disp(' ');
   disp(' ');disp('   ¡¡The system has not double checked that both keys are coupled!!');
             disp('          ¡¡This wallet has been created at your own risk!!');
   disp(' ');disp('   I strongly recommend you to run QuarkBTCwallet again,')
             disp('   but entering only the private key to verify the result');
end

% Once imported or generated the secret key and address, lets break it in
% three "quarks" for meta-blockchain cold storage
if noproblemo
  for i=1:length(secret);kk(i)='#';end
  secret3=[kk(1:18) secret(19:end)];                 visualQRwallet(addres,secret3,3)
  secret2=[secret(1:18) kk(19:35) secret(36:end)];   visualQRwallet(addres,secret2,2)
  secret1=[secret(1:35) kk(36:end)];                 visualQRwallet(addres,secret1,1)
  
  
end
end



function [addres,pub_key]=BTCaddress(px,py,compressed)

if compressed==1
    if mod(hex2dec(py(64)),2)==0;   pub_key=['02' px];
    else;                           pub_key=['03' px];
    end;else                        pub_key=['04' px py];
end

%P2PKH (address starts with number “1”)
riped=ripemd160(SHA256(pub_key));
ch_sum=SHA256(SHA256(['00' riped]));
addres=['1'  hex2b58(['00' riped ch_sum(1:8)])];
    
%Segwit Bech32 (address starts with “bc1”)... for next version  
end


function visualQRwallet(addres,secret,ii)

z1=QRencoder(addres,1);
z2=QRencoder(secret,1);

% Preparing the display of the wallet
[x,y]=meshgrid([0:83],[-5 3:44 50]);
separ=43;x(:,40:84)=x(:,40:84)+separ;
%%% Designing the visual aspect of the paper wallet
figure('Name',[' Quark BTC paper wallet (' num2str(ii) ' of 3) Meta-blockchain philosophy.']);hold on;
pcolor(x,y,x.*0+1)% White background
plot([0 83+separ 83+separ 0 0],[-5 -5 50 50 -5],'k')% Margin
plot([39 36+separ 36+separ 39 39], [22 22 32 32 22],'k','LineWidth',1.1)

% Plotting both QR
pcolor(x(2:35,2:35),y(10:43,9:42),z1')
pcolor(x(2:end-1,42:83),y(2:end-1,42:83),z2');colormap gray;
axis equal;shading flat;try;set(gca,'xtick',[],'ytick',[]);end
% Adding text
if ii==1;abc='AB#)';elseif ii==2;abc='A#C)';else;abc='#BC)';
end
text(1,5,['BTC adress (Share): ' addres],'fontweight','bold')
text(1,-1,['Secret key (WIF): ' secret],'fontweight','bold')
text(10,47,'Share','FontSize', 12,'fontweight','bold');text(40,34.5,'Wallet Name:','FontSize', 10,'fontweight','bold');
text(10+separ+32,47,['SECRET.      (' abc],'FontSize', 12,'fontweight','bold','Color',[1 0 0])
text(1,64,'Print and save offline (maximize figure if text is unreadable)','FontSize', 12,'fontweight','bold')
text(5,60,'Keep each wallet of the same address in a different place. Your BTCs are safe') 
text(5,56,'even if one of the three wallets is lost or stolen')
end

