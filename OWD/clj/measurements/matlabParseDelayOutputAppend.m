%read text file
%text = fileread('test.txt');
text = fileread('delayOutputAppend.txt');
%split each measurement sample
measurements = strsplit(text,'x');

%vectorul pentru timp
timeInitial=zeros(numel(measurements)-1,1);
OWD12=zeros(numel(measurements)-1,1);
OWD13=zeros(numel(measurements)-1,1);
OWD14=zeros(numel(measurements)-1,1);
OWD21=zeros(numel(measurements)-1,1);
OWD23=zeros(numel(measurements)-1,1);
OWD24=zeros(numel(measurements)-1,1);
OWD31=zeros(numel(measurements)-1,1);
OWD32=zeros(numel(measurements)-1,1);
OWD34=zeros(numel(measurements)-1,1);
OWD41=zeros(numel(measurements)-1,1);
OWD42=zeros(numel(measurements)-1,1);
OWD43=zeros(numel(measurements)-1,1);

OWD12old = 0;
OWD13old = 0;
OWD14old = 0;
OWD21old = 0;
OWD23old = 0;
OWD24old = 0;
OWD31old = 0;
OWD32old = 0;
OWD34old = 0;
OWD41old = 0;
OWD42old = 0;
OWD43old = 0;



format long

for i=2:numel(measurements)
    % impartire pe linii a fiecarui stamp de masuratori
    line = strsplit(measurements{i},'\n');
    numel(line)-1;
    line{1}; %linia cu timpul
    timeInitial(i-1) = str2double(line{1});
    %processing
    
    %procesare n1-n2
    stringToBeSearched = 'n1-n2';
    for k=2:(numel(line)-1)
        nameAndOWD = strsplit(line{k},' ');
        if(strcmp(stringToBeSearched,nameAndOWD{1}))
            OWD12(i-1) = str2double(nameAndOWD{2});
            OWD12old = str2double(nameAndOWD{2});
        end
    end
    if (OWD12(i-1)==0)
        OWD12(i-1)=OWD12old;
    end
    
    
    
    
    %procesare n1-n3
    stringToBeSearched = 'n1-n3';
    for k=2:(numel(line)-1)
        nameAndOWD = strsplit(line{k},' ');
        if(strcmp(stringToBeSearched,nameAndOWD{1}))
            OWD13(i-1) = str2double(nameAndOWD{2});
            OWD13old = str2double(nameAndOWD{2});
        end
    end
    if (OWD13(i-1)==0)
        OWD13(i-1)=OWD13old;
    end
                
    
    %procesare n1-n4
    stringToBeSearched = 'n1-n4';
    for k=2:(numel(line)-1)
        nameAndOWD = strsplit(line{k},' ');
        if(strcmp(stringToBeSearched,nameAndOWD{1}))
            OWD14(i-1) = str2double(nameAndOWD{2});
            OWD14old = str2double(nameAndOWD{2});
        end
    end
    if (OWD14(i-1)==0)
        OWD14(i-1)=OWD14old;
    end
    
    %procesare n2-n1
    stringToBeSearched = 'n2-n1';
    for k=2:(numel(line)-1)
        nameAndOWD = strsplit(line{k},' ');
        if(strcmp(stringToBeSearched,nameAndOWD{1}))
            OWD21(i-1) = str2double(nameAndOWD{2});
            OWD21old = str2double(nameAndOWD{2});
        end
    end
    if (OWD21(i-1)==0)
        OWD21(i-1)=OWD21old;
    end
    
    %procesare n2-n3
    stringToBeSearched = 'n2-n3';
    for k=2:(numel(line)-1)
        nameAndOWD = strsplit(line{k},' ');
        if(strcmp(stringToBeSearched,nameAndOWD{1}))
            OWD23(i-1) = str2double(nameAndOWD{2});
            OWD23old = str2double(nameAndOWD{2});
        end
    end
    if (OWD23(i-1)==0)
        OWD23(i-1)=OWD23old;
    end
    
    
    %procesare n2-n4
    stringToBeSearched = 'n2-n4';
    for k=2:(numel(line)-1)
        nameAndOWD = strsplit(line{k},' ');
        if(strcmp(stringToBeSearched,nameAndOWD{1}))
            OWD24(i-1) = str2double(nameAndOWD{2});
            OWD24old = str2double(nameAndOWD{2});
        end
    end
    if (OWD24(i-1)==0)
        OWD24(i-1)=OWD24old;
    end
    
    
    %procesare n3-n1
    stringToBeSearched = 'n3-n1';
    for k=2:(numel(line)-1)
        nameAndOWD = strsplit(line{k},' ');
        if(strcmp(stringToBeSearched,nameAndOWD{1}))
            OWD31(i-1) = str2double(nameAndOWD{2});
            OWD31old = str2double(nameAndOWD{2});
        end
    end
    if (OWD31(i-1)==0)
        OWD31(i-1)=OWD31old;
    end
    
    
    %procesare n3-n2
    stringToBeSearched = 'n3-n2';
    for k=2:(numel(line)-1)
        nameAndOWD = strsplit(line{k},' ');
        if(strcmp(stringToBeSearched,nameAndOWD{1}))
            OWD32(i-1) = str2double(nameAndOWD{2});
            OWD32old = str2double(nameAndOWD{2});
        end
    end
    if (OWD32(i-1)==0)
        OWD32(i-1)=OWD32old;
    end
                
    
    %procesare n3-n4
    stringToBeSearched = 'n3-n4';
    for k=2:(numel(line)-1)
        nameAndOWD = strsplit(line{k},' ');
        if(strcmp(stringToBeSearched,nameAndOWD{1}))
            OWD34(i-1) = str2double(nameAndOWD{2});
            OWD34old = str2double(nameAndOWD{2});
        end
    end
    if (OWD34(i-1)==0)
        OWD34(i-1)=OWD34old;
    end
    
    
    %procesare n4-n1
    stringToBeSearched = 'n4-n1';
    for k=2:(numel(line)-1)
        nameAndOWD = strsplit(line{k},' ');
        if(strcmp(stringToBeSearched,nameAndOWD{1}))
            OWD41(i-1) = str2double(nameAndOWD{2});
            OWD41old = str2double(nameAndOWD{2});
        end
    end
    if (OWD41(i-1)==0)
        OWD41(i-1)=OWD41old;
    end
    
    
    %procesare n4-n2
    stringToBeSearched = 'n4-n2';
    for k=2:(numel(line)-1)
        nameAndOWD = strsplit(line{k},' ');
        if(strcmp(stringToBeSearched,nameAndOWD{1}))
            OWD42(i-1) = str2double(nameAndOWD{2});
            OWD42old = str2double(nameAndOWD{2});
        end
    end
    if (OWD42(i-1)==0)
        OWD42(i-1)=OWD42old;
    end
    
    
    %procesare n1-n4
    stringToBeSearched = 'n4-n3';
    for k=2:(numel(line)-1)
        nameAndOWD = strsplit(line{k},' ');
        if(strcmp(stringToBeSearched,nameAndOWD{1}))
            OWD43(i-1) = str2double(nameAndOWD{2});
            OWD43old = str2double(nameAndOWD{2});
        end
    end
    if (OWD43(i-1)==0)
        OWD43(i-1)=OWD43old;
    end
    

end


%%%%creare vector timp incepand din 0
time=zeros(length(timeInitial),1);
for i=1:length(timeInitial)
    time(i)=timeInitial(i)-timeInitial(1);
end



            
format long
fid=fopen('neu-bor.txt','w');
fprintf(fid,'%f\n',OWD12);
fclose(fid);

fid=fopen('neu-lan.txt','w');
fprintf(fid,'%f\n',OWD13);
fclose(fid);

fid=fopen('neu-clj.txt','w');
fprintf(fid,'%f\n',OWD14);
fclose(fid);

fid=fopen('bor-neu.txt','w');
fprintf(fid,'%f\n',OWD21);
fclose(fid);

fid=fopen('bor-lan.txt','w');
fprintf(fid,'%f\n',OWD23);
fclose(fid);

fid=fopen('bor-clj.txt','w');
fprintf(fid,'%f\n',OWD24);
fclose(fid);

fid=fopen('lan-neu.txt','w');
fprintf(fid,'%f\n',OWD31);
fclose(fid);

fid=fopen('lan-bor.txt','w');
fprintf(fid,'%f\n',OWD32);
fclose(fid);

fid=fopen('lan-clj.txt','w');
fprintf(fid,'%f\n',OWD34);
fclose(fid);

fid=fopen('clj-neu.txt','w');
fprintf(fid,'%f\n',OWD41);
fclose(fid);

fid=fopen('clj-bor.txt','w');
fprintf(fid,'%f\n',OWD42);
fclose(fid);

fid=fopen('clj-lan.txt','w');
fprintf(fid,'%f\n',OWD43);
fclose(fid);

fid=fopen('time.txt','w');
fprintf(fid,'%f\n',time);
fclose(fid);


