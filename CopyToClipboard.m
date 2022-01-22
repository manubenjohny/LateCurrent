

function CopyToClipboard(Data, StrColHeaders, StrRowHeaders)
%function CopyToClipboard(Data, StrColHeaders, StrRowHeaders)
%
%copies Data (a 2-D matrix) to the clipboard in an Excel-Friendly format
%StrColHeaders, StrRowHeaders are optional, set to [] if not required.
%example: CopyToClipboard(Data, {'Header1' 'Header2'}, [])

%Error check
if ~isempty(StrColHeaders) & length(StrColHeaders)~=size(Data,2)
    error('length of StrColHeaders must be equal to the number of columns in Data');
end
if ~isempty(StrRowHeaders) & length(StrRowHeaders)~=size(Data,1)
    error('length of StrRowHeaders must be equal to the number of rows in Data');
end

Str = '';

%First do the column headers if they exist
if ~isempty(StrColHeaders)
    if ~isempty(StrRowHeaders)
        Str = [Str  '\t'];    %one tab to make room for row headers
    end
    for j=1:size(Data,2)
        if j>1
            Str = [Str  '\t'];   
        end
        Str = [Str  StrColHeaders{j}]; 
    end
    Str = [Str '\n'];  %end of row has a newline
end
    
%Now do the data. 
for k=1:size(Data,1)
    Tmp{k} = '';
    if ~isempty(StrRowHeaders)
        Tmp{k} = [StrRowHeaders{k} '\t'];  
    end
    Tmp{k} = [Tmp{k}  num2str(Data(k,1:end), '%10.10f \t')   '\n'];
end
Str = [Str Tmp{:}];

clipboard('copy', sprintf(Str));
