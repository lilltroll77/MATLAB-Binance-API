function [T,response] = loanRecord(asset,symbol,OPT)
% loanRecord returns loan record.
%
% limit default: 10, max:100
%
% Example:
%  >> [T,r] = imargin.loanRecord('btc','startTime',datetime()-days(10))

arguments
asset           (1,:) char 	
symbol          (1,:) char
OPT.txId 		(1,1) double

OPT.startTime 	(1,1)
OPT.endTime 	(1,1)

OPT.limit 		(1,1) double    = 10
OPT.archived 	(1,1) logical   = false
OPT.recvWindow 	(1,:) double    = 5000
OPT.username (1,:) char      = 'default'
end

OPT.asset = upper(asset);
OPT.isolatedSymbol = upper(symbol);

if isfield(OPT,'startTime')
    validateattributes(OPT.startTime,{'double','datetime'},{})
    if isa(OPT.startTime,'datetime')
        OPT = datetime2posix(OPT,'startTime');
    end
end
if isfield(OPT,'endTime')
    validateattributes(OPT.endTime,{'double','datetime'},{})
    if isa(OPT.endTime,'datetime')
        OPT = datetime2posix(OPT,'endTime');
    end
end

if all(isfield(OPT,{'startTime','txId'}))
    warning('txId takes precedence over startTime.')
end
if all(isfield(OPT,{'endTime','txId'}))
    warning('txId takes precedence over endTime.')
end

OPT.size = OPT.limit;
OPT = rmfield(OPT,'limit');

endPoint = '/sapi/v1/margin/loan';
response = sendRequest(OPT,endPoint,'GET');
d = response.Body.Data;
%T = struct2table(response.Body.Data);

if isa(d,'struct') && isa(d.rows,'struct')
    T = struct2table(d.rows,'AsArray',true);
    
    T.timestamp = datetime(T.timestamp/1e3,...
        'ConvertF','posix','TimeZ','local');
    
    T.Properties.VariableNames{1} = 'time';
    T = table2timetable(T);
else
    T = [];
end

    
end
