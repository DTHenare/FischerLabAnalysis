function writeToText()
try
    [files,dataFolder] = uigetfile('*_data.mat','Select the data files you want analysed','MultiSelect', 'on');
    
    
    
    
    
    
    for f = 1 : length(files)
        file = strcat(dataFolder,files{f});
        
        [path, name, ~] = fileparts(file);
        
        thisData = load(file);
        
        responses = squeeze((struct2cell(thisData.responseStruct)))';
        
        if size(responses,1) == 800 % each data file should have 800 trials
            
            
            catchtrials = find(ismember(responses(:,4),'c'));
            
            responses(catchtrials,6) = {0}; % blank out the delay on catch trials because they all have the same delay
            
            catchTrialsErrors = sum(cell2mat(responses(catchtrials,3)) == 0);
            
            exptrials = setdiff(1:800,catchtrials)';
            
            otherErrors = sum(cell2mat(responses(exptrials,3)) == 0);
            
            totalErrors = catchTrialsErrors + otherErrors;
            
            disp(['The file ' file ' contains ' ...
                num2str(totalErrors) ' errors (' ...
                num2str(totalErrors/8) '%), of which ' ...
                num2str(catchTrialsErrors) ...
                ' (' num2str(catchTrialsErrors/8)...
                '%) are errors on catch trials.']);
            
            disp('writing to txt...')
            
            
            
            
            writeTextArray(vertcat({'RT','Correct','Target','Cue','Delay'},responses(:,[1 3 4 5 6])),...
                [path filesep name '.txt']);
            
            
        else
            warning(['The file ' file ' is incomplete. Skipping...']);
        end
        %goodTrials = thisData.responseStruct((vertcat(thisData.responseStruct.correct) == 1));
        %goodTrials = struct2table(goodTrials);
        %goodTrials.SubjectCode = repmat({thisData.params.subCode},height(goodTrials),1);
        %writetable(goodTrials,[thisData.params.subCode '.csv'])
    end
catch ME
    save('ErrorCheck.mat','ME','files')  
end
end
function success = writeTextArray(C,filename)
% success = writetextarray(C,filename)
fid = fopen(filename,'wt');

[M,N] = size(C);
for i=1:M-1
    for j=1:N-1
        bit = C{i,j};
        fprintf(fid, '%s\t',numIfstr(bit));
    end
    bit = C{i,N};
    fprintf(fid, '%s',numIfstr(bit));
    fprintf(fid, '\n');
end

for i=M
    for j=1:N-1
        bit = C{i,j};
        fprintf(fid, '%s\t',numIfstr(bit));
    end
    bit = C{i,N};
    fprintf(fid, '%s',numIfstr(bit));
end

fclose all;
success = 1;
end

function out = numIfstr(bit)
if isnumeric(bit) == 1
    out = num2str(bit);
else
    out = bit;
end
end