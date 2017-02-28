%Program that performs estiamtions of OWD 
%form: HostName ProcTime

fileID = fopen('ready.txt','w');
%%----for practical demonstration - append
fileIDappend = fopen('measurements/delayOutputAppend.txt','w');
fclose(fileIDappend);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fclose(fileID);

while 1	
	%waiting for permision from the C Program
    pause(1/10);
    ready = fileread('ready.txt');
    if(strcmp(ready,'c'))

		%%%%%%%%%%processing 
		hostname = cell(1);
		hostnameCount=1;
		linkTable = cell(1);
		linkCount=1;
		%TPjos = 0.00015;
	
		% read file 
		text = fileread('delay.txt');

		%split the string in equations
		EQandRTT = strsplit(text,'|');  %split in equations
		EQ = cell(numel(EQandRTT)-1,1);
		RTT = zeros(numel(EQandRTT)-1,1);
		RTT1=0;
		RTTfinal =0;
	
		% START parsing each equation
		for i=1:(numel(EQandRTT)-1)
			A = strsplit(EQandRTT{i},'?');  %split equation and RTT
			format long
		
			%split the equation in: hostname;time;procTime  : B{1} = hostname B{2}=procTime
			B = textscan(A{1},'%s %s');
			EQ{i} = B{1};
			
		
			%GOOOOOD
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%START
			%compute the RTT - procTime(j) --> the final RTT for each equation
			rtt = str2num(A{2});   %RTT for each equation
			for j=1:(size(B{2}))(1);
				procTime = str2num(B{2}{j});
				rtt=rtt - procTime;
			end
			RTT(i,1)=rtt;   % RTT (TPjos e considerat null datorit Compute2)  
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END
		
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%START
			%GOOOOOD
			%create a cell array with all the hostnames : cell array hostname[noHost,1]
			for j=1:(size(B{1}))(1);
				if(strcmp(hostname,B{1}{j})==0)
					hostname{hostnameCount,1}=B{1}{j};
					hostnameCount=hostnameCount+1;
				end
			end	
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END
		
		
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%START
			%GOOOOOD
			%create table with all links: cell array linkTable[1,noLinks]
			s1=size(B{1});
			s=s1(1)-1;
			for j=1:s;
				if(strcmp(B{1}{j},B{1}{j+1})==0)   %check if is loopback
					link=strcat(B{1}{j},'-',B{1}{j+1});
					if(strcmp(linkTable,link)==0)
						linkTable{1,linkCount} = link;
						linkCount = linkCount+1;
					end
				end
			end
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END
        
		end

		linkTable;
	
		%%%%%%%%%avem : - EQ{i} - prima coloana care contine nodurile prin care a trecut
					%- RTT(i) - contine RTT final, in afara de TPjos din sursa si cu TPjos din clienti (considerat NULL in Compute2) (setat la 0.15 ms in Compute1)
					%- hostname table
					%- link table (e verificata conditia de loopback !!!!!!!!!!)
	
	
		%%%%%%%%%%%%%%%% se obtine RTT(i) FINAL FINAL FINAL  - se scade TPjosSursa 
		TPjosSursa = RTT(1,1);
		for i=1:numel(RTT)
			RTT(i,1) = RTT(i,1) - TPjosSursa;
		end
		%%%%%%%%%%%%%%%%%%%%%%%%% FINAL
	
		M = [];
		count=1;
		%MATRIX Generation
		%%%%% it is generated a matrix and RTTfinal only with the rows(equations) containing the links which appear only once
		for i=1:numel(EQ);	
			if (strcmp(EQ{i}{1},EQ{i}{2}) == 0)
				v= zeros(size(linkTable));
				s1=size(EQ{i});
				s=s1(1)-1;
				for j=1:s;
					link=strcat(EQ{i}{j},'-',EQ{i}{j+1});
					index=find(strcmp(linkTable,link));
					v(index)=v(index)+1;
				end
				if (~(any(v(:) > 1)))
					M=vertcat(M,v);
					RTT1(count,1)=RTT(i);
					count = count+1;
				end
			end
			
        end
  
        if (size(M)~=[0,0])
    
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%START
            %generate the final Matrix and RTT ( the ones that give the maximum grade)
            Mfinal=M(1,:);
            RTTfinal(1,1)=RTT1(1);
            i=2;
            while rank(Mfinal) < rank(M)
            	new = vertcat(Mfinal, M(i,:));
            	if (rank(new)~=rank(Mfinal))
                	Mfinal=new;
                	RTTfinal = vertcat(RTTfinal, RTT1(i));
                end
            	i=i+1;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%END
    
            Mfinal;
            RTTfinal;

            [line column] = size(Mfinal);
            RTTextraEq = 0;      %coloana cu domeniile de baleiere pt ecuatiile introduse
            RTTextraEqTable=[];  %tabel cu cele 10 valori din domeniul de baleiere pt fiecare ecuatie noua
            count=1;
            for i=1:line
                for j=1:column
                    if (Mfinal(i,j)==1)   %se va incerca adaugarea unui vector cu un singur element 1
                        v=zeros(1,column);
                        v(1,j)=1;
                        new = vertcat(Mfinal,v);
                        if ((rank(new)~=rank(Mfinal))&(rank(new)<=column)) 
                            Mfinal=new;
                            RTTextraEq(count,1)= RTTfinal(i,1);   %se ia valoarea
                            w=linspace(0,RTTfinal(i,1),10);       %se genereaza vectorul de 10 valori pt fiecare
                            RTTextraEqTable=vertcat(RTTextraEqTable,w);  %se creaza tabel cu valorile
                            count=count+1;
                        end
                    end
                end
            end

            Mfinal;       %e matricea finala de rang maxim !!!!!
            RTTfinal;    %e coloana cu RTT pt matricea de rang mai mic
            RTTextraEq;  %e coloana cu RTT ce se vor baleia   

            RTTextraEqTable;  %e tabelul din care se vor lua combinarile pt a crea sistem determinat      


            RTTextraCombinations = RTTextraEqTable(1,:);  %va fi tabela cu toate combinarile
            [line,column] = size(RTTextraEqTable);
            for i=2:line
                RTTextraCombinations=combvec(RTTextraCombinations,RTTextraEqTable(i,:));
            end
            RTTextraCombinations;     


            [line ,column] = size(Mfinal);
            Y=zeros(line,1);
            count=0;
            [line, column] = size(RTTextraCombinations);
            for i=1:column
                RTT = vertcat(RTTfinal,RTTextraCombinations(:,i));       
                x=linsolve(Mfinal,RTT);
                if x>0 
                    Y=Y+x;
                    count=count+1;
                end    
            end

            linkTable=linkTable.';
            YY=cell2mat(linkTable);
            Y=Y/count;

            if (~any(isnan(Y(:))))
                fileID = fopen('delayOutput.txt','w+');
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%% for practical demonstration
                fileIDappend = fopen('measurements/delayOutputAppend.txt','a');
                time=clock;
                timeNumber = time(6)+time(5)*60+time(4)*60*60;
                fprintf(fileIDappend,'x%.3f\n',timeNumber);
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                formatSpec = '%s %.10f\n' ;
                [nrows,ncols] = size(linkTable);
                fprintf('\n\n');
                for row= 1:nrows-1
                    fprintf(fileID,formatSpec,linkTable{row,:},Y(row));
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for practical demonstration
                    fprintf(fileIDappend,formatSpec,linkTable{row,:},Y(row));
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    fprintf(formatSpec,linkTable{row,:},Y(row));
                end
                formatSpec = '%s %.10f' ;
                fprintf(fileID,formatSpec,linkTable{nrows,:},Y(nrows));
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% for practical demonstration
                fprintf(fileIDappend,formatSpec,linkTable{nrows,:},Y(nrows));
                fprintf(fileIDappend,'\n');
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                fprintf(formatSpec,linkTable{nrows,:},Y(nrows));
                fclose(fileID);
            end
            %%%%%%%%%%%%%END PROCESSING

            fileID = fopen('ready.txt','w+');
            fprintf(fileID,'m');
            fclose(fileID);
        else
            fileID = fopen('ready.txt','w+');
            fprintf(fileID,'m');
            fclose(fileID);
            
        end
    end  %END this: if(strcmp(ready,'c'))
end %END while(1)
	
