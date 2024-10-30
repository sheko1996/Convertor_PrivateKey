function [addres,secret,pub_key,pr_key]=BTCwallet
% BTCwallet
%
% [addres,secret,pub_key,pr_key]=BTCwallet
%
% After clicking randomly in a white screen to generate entropy, a paper wallet
% surges as in image, containing public and private keys (properly address and WIF) 
% expressed both in text and QR codes (in base58, as usual). 
% 
% Adress and private key (WIF) are also displayed in the command window 
%
% Optional outputs, pub_key and pr_key, are provided in hexadecimal format
%
% You should run this program offline to maximize your safety. Several
% functions, such as QRencoder, have been completely rewritten in native 
% Matlab language, so that everything should work fine offline and
% regardless of the Matlab version.
%
% This scritp calls the functions:   secp256k1 SHA256.m, ripemd160.m, 
%                                    hex2b58 and QRencoder.m,
%
%
%%%%%%%%%%% ABOUT ENTROPY "BOMB"... PLEASE READ FOR YOUR OWN SAFETY %%%%%%%%%%%%%%%%%%
%                                                                                    %
%  All the operations applied here, once we have a private key, are "one-way"        %
%  functions, perfectly defined and documented                                       %
%                                                                                    %
%  The bottleneck, or single point of failure of the whole process, is the           %
%  generation of the private key. It is supposed to be random and private, but       %
%  artificial devices generate pseudo-randomness and the Internet connection         %
%  can open back doors where your keys can be stolen.                                %
%                                                                                    %
%  That is why I explain here in detail each step of the process followed to         %
%  generate the private key, as it must be completely safe, random and transparent   %
%                                                                                    %
%  If you have a mathematical background you may be tempted to define another way    % 
%  to achieve randomness, since this system is really  simple. But, if you don't     %
%  have much knowledge, please be careful. Some mathematical operations can          %
%  induce a loss of randomness in each of the 64 digits that make up the private     %
%  key (in hexadecimal)                                                              %
%                                                                                    %
%  As an example, if an ideal die is rolled, the probability of each number is 1/6;  %
%  but if the sum of two ideal dice is recorded, the value '2' can only come out one % 
%  time out of all possible ones (as 1+1), while, the value '4' can come out as 1+3, %
%  2+2 and 3+1, i.e., it is three times more likely. If this happens in something as %
%  simple as addition, think that other more complicated operations can reduce even  %
%  more the randomness of the results                                                % 
%                                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%....... so let' start

%%%%%%%%%%%%%%%%%%%% ENTROPY "BOMB" %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Just giving format and writting text in the screen 
h=figure('Name',' Human entropy generator window ');
plot([0 5 5], [0 0 5],'k.');hold on;try;set(gca,'xtick',[],'ytick',[]);end
text(0.25,2.5,['Click 100 times in this screen randomly... chaotically'],'FontSize', 12,'fontweight','bold')
text(0.05,0.7,['...humanized entropy is required to generate really random private keys'])
text(0.05,0.2,['... make stupid patterns... the more stupid... ¡¡the better!!'])
disp('Please generate entropy for the private key by clicking in the figure');

% Storing an 'entropy vector' attending to the clicks in the screen (100 clicks)
% The screen area is x ? [0,5] and y ?[0,5]. The decimal part of the coordinates
% of each click is the initial source of random values
xy=get(gca,'currentpoint');i=0;
while i<100;
    xy0=xy(1,1:2);pause(0.1)
    xy=get(gca,'currentpoint');xy1=xy(1,1:2);
    if sum(abs(xy0-xy1))==0;else;i=i+1;% If new click, get the new value
       xy=mod(xy1,5);xy_acum(i,:)=xy;       
       % Decimal part of the coordinates are random. Notice that the
       % coordinate isn't random as there is a natural trend to click 
       % more frequently near the center. Vector 'entrop' get this decimal 
       % part in 16 stretches to be easily converted to hexadecial base
       entrop(2*i-1:2*i)=floor((xy-floor(xy)).*16);
       % Just plotting to entertain the user
       plot(xy_acum(:,1),xy_acum(:,2),'b:');
       text(xy(1),xy(2),[num2str(i) '%']); drawnow;
    end
end

% STOP message in a new screen to avoid risky unintentional clicks
[x,y]=meshgrid ([0 5],[0 5]);pcolor(x,y,x.*0+1);colormap gray
text(0.3,1,'You BTC wallet will be ready in about 15 seconds','FontSize', 12,'fontweight','bold');
text(1.3,3,'¡¡¡STOP!!!' ,'FontSize', 30,'fontweight','bold');drawnow;

% Entropy, keeping it simple: 
%          Each hexadecimal digit of the private key, 64 digits long, is 
%          obtainend from the 'entrop' vector previously stored, as follows: 
%          Alternatively it gets: Decimal part of x, decimal part of y, and nothing
%          The 64 hexadecimal digits number created with this simple method
%          will be hashed (SHA256) to generate the public key
hexchar='0123456789ABCDEF';for i=1:64;pr_key(i)=hexchar(1+entrop(3*i+6));end
pr_key=SHA256(pr_key);
%%%%%%%%%%%%%%%%%%%% END OF ENTROPY "BOMB". pr_key is generated %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% First of all, let's validate your Matlab version. Security is the priority
validate_matlab_version;% If your Matlab version or hardware has any problem, the execution will break


% Applying Elliptic curve cryptography (ECDSA) to obtain public key (file secp256k1.m)
[px,py]=secp256k1(pr_key);


% Obtaining the two wallet strings in base 58: address and secret(WIF) (local functions)
compressed=1;
[addres,pub_key]=BTCaddress(px,py,compressed);      close (h);pause(0.05);clc;try;close(h);end
                                                    disp(' ');disp('... wait 10 seconds more while public key');
                                                    disp('and address are calculated and verified...')
secret          =WIF(pr_key,compressed);



% Generating the cold wallet plot, with both QR and text formats (local function)
visualQRwallet(addres,secret)


%%%  Output in command window... don't forget to sponsor me a cofee ;) 1LLV93YJCF4FLXaryjtPzKRWqBbsg2BdX1 %%%%%%%%%
clc;disp (' '); disp('Copy this info and keep it in a safe (offline and duplicated) place');
disp (' ');     disp(['Secret (WIF): ' secret]);
                disp(['Address     : ' addres]);
disp (' ');     disp('You can safely share your address and start receiving bitcoins right now!!');
disp(' ');      disp(['Did you like it?  ...you can celebrate']);
                disp(['by sending me some ' char(181) 'BTC for a coffee ;)   1LLV93YJCF4FLXaryjtPzKRWqBbsg2BdX1']);
disp(' ');      disp('');
end




function secret=WIF(pr_key,compressed)
% secret=WIF(pr_key,compressed)
%
% Returns the Wallet Interchange Format (base 58) from a private key introduced in hex,

% Adjusting the length to 64 digits 
Os(1:64-length(pr_key))='0';pr_key=[Os pr_key];
if compressed==1;   k=['80' pr_key '01'];  
else;               k=['80' pr_key];
end

hash2=SHA256(SHA256(k));
secret=hex2b58([k hash2(1:8)]);
end


function [addres,pub_key]=BTCaddress(px,py,compressed)

if compressed==1
    if mod(hex2dec(py(end)),2)==0;  pub_key=['02' px];
    else;                           pub_key=['03' px];
    end;else                        pub_key=['04' px py];
end

%P2PKH (address starts with number “1”)
riped=ripemd160(SHA256(pub_key));
ch_sum=SHA256(SHA256(['00' riped]));
addres=['1'  hex2b58(['00' riped ch_sum(1:8)])];
    
%Segwit Bech32 (address starts with “bc1”)... for next version  
end


function visualQRwallet(addres,secret)

z1=QRencoder(addres,1);
z2=QRencoder(secret,1);

% Preparing the display of the wallet
[x,y]=meshgrid([0:83],[-5 3:44 50]);
separ=43;x(:,40:84)=x(:,40:84)+separ;
%%% Designing the visual aspect of the paper wallet
figure('Name',' Paper wallet. Classic format');hold on;
pcolor(x,y,x.*0+1)% White background
plot([0 83+separ 83+separ 0 0],[-5 -5 50 50 -5],'k')% Margin
plot([39 36+separ 36+separ 39 39], [22 22 32 32 22],'k','LineWidth',1.1)

% Plotting both QR
pcolor(x(2:35,2:35),y(10:43,9:42),z1')
pcolor(x(2:end-1,42:83),y(2:end-1,42:83),z2');colormap gray;
axis equal;shading flat;try;set(gca,'xtick',[],'ytick',[]);end
% Adding text
text(1,5,['BTC adress (Share): ' addres],'fontweight','bold')
text(1,-1,['Secret key (WIF): ' secret],'fontweight','bold')
text(10,47,'Share','FontSize', 12,'fontweight','bold');text(40,34.5,'Wallet Name:','FontSize', 10,'fontweight','bold');
text(10+separ+45,47,'SECRET','FontSize', 12,'fontweight','bold','Color',[1 0 0])
text(10,60,'Print and save offline (maximize figure if text is unreadable)','FontSize', 12,'fontweight','bold')
text(10,55,'For extra security try QuarkBTCwallet. Meta-blockchain, philosophy  ;)','FontSize', 10,'fontweight','bold','Color',[1 0 0])

end

