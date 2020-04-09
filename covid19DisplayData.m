% covid19DisplayData
% Authors:
%   (c) Matthias Chung (e-mail: mcchung@vt.edu)     in March 2020         
%       
% This small app downloads Covid-19 data, plots data and saves data by
% selected contries, creating a structure with country name and counts of
% confirmed infected, recovered, and deaths. The data is downloaded from 
% https://github.com/CSSEGISandData/COVID-19, please see github webpage for
% more information on data restrictions.
%
% This is not a perfect app, it should just help other researchers to
% download and easily use up-to-date Covid-19 data.
%
% MATLAB Version: 9.6.0.1072779 (R2019a)

close, clear 

fprintf('\n(c) Matthias Chung (e-mail: mcchung@vt.edu) in March 2020  \n\n')

downloadFiles
allData = loadData;

covid19APP = uifigure('Name','covidApp','Position',[20 20 270 250]);
countryDropDown  = uidropdown(covid19APP,'Items',allData.uniqueNames,...
  'Value','US','Position',[20 20 120 22]);
  
btn = uibutton(covid19APP,'push','Text','show plots',...
  'Position',[150, 20, 100, 22],...
  'ButtonPushedFcn', @(btn,event) computeData(btn,countryDropDown.Value, allData));

dwld = uibutton(covid19APP,'push','Text','download data',...
  'Position',[150, 70, 100, 22],...
  'ButtonPushedFcn', @(dwld,event) downloadFiles);

%%

function downloadFiles
fprintf('Downloading data from:\n\n')
fprintf('Novel Coronavirus (COVID-19) Cases, provided by John Hopkins University CSSE\n')
fprintf('Data sources: WHO, CDC, ECDC, NHC, DXY, 1point3acres, Worldometers.info,\n')
fprintf('BNO, state and national government health departments, and local media reports.\n\n')
fprintf('see: https://github.com/CSSEGISandData/COVID-19\n\n')
fprintf('Terms and Conditions from https://gisanddata.maps.arcgis.com/apps/opsdashboard/index.html#/bda7594740fd40299423467b48e9ecf6\n\n')
fprintf('Terms and Conditions of Website Use:  This website and its contents herein, including all data,\n')
fprintf('mapping, and analysis (?Website?), copyright 2020 Johns Hopkins University, all rights reserved,\n')
fprintf('is provided to the public strictly for public health, educational, and academic research purposes.,\n') 
fprintf('Redistribution of the Website or the aggregated data set underlying the Website is strictly prohibited.,\n')  
fprintf('You are welcome to link to the Website, however.  The Website relies upon publicly available data,\n') 
fprintf('from multiple sources that do not always agree. The Johns Hopkins University hereby disclaims any and,\n') 
fprintf('all representations and warranties with respect to the Website, including accuracy, fitness for use,\n')
fprintf('reliability, and non-infringement. Reliance on the Website for medical guidance or use of the Website in,\n') 
fprintf('commerce is strictly prohibited.  Any use of the Johns Hopkins? names, logos, trademarks, and trade dress,\n') 
fprintf('for promotional or commercial purposes is strictly prohibited.\n\n') 
urlFolder = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/';
fprintf('Downloading data from github.com...')
filename = 'time_series_covid19_confirmed_global.csv'; url = [urlFolder,filename]; websave(filename,url);
filename = 'time_series_covid19_recovered_global.csv'; url = [urlFolder,filename]; websave(filename,url);
filename = 'time_series_covid19_deaths_global.csv';    url = [urlFolder,filename]; websave(filename,url);
filename = 'time_series_covid19_confirmed_US.csv';     url = [urlFolder,filename]; websave(filename,url);
filename = 'time_series_covid19_deaths_US.csv';        url = [urlFolder,filename]; websave(filename,url);
fprintf(' done.\n')
end

function d = computeData(~,country,allData)
startDate = 5;
selectedData = selectData(country,startDate,allData);
plotData(selectedData,country);
d = selectedData;
saveName = ['covid19_data_',d.selectedName,'.mat'];
save(saveName,'d')
% global d
end

function allData = loadData
fprintf('Loading data...')
confirmed = readtable('time_series_covid19_confirmed_global.csv');
deaths    = readtable('time_series_covid19_deaths_global.csv');
recovered = readtable('time_series_covid19_recovered_global.csv');
allData.countryNames  = confirmed{:,2};
allData.provinceNames = confirmed{:,1};
allData.uniqueNames   = unique(allData.countryNames);
allData.confirmed     = confirmed;
allData.deaths        = deaths;
allData.recovered     = recovered;
fprintf(' done.\n')
end

function selectedData = selectData(country,startDate,allData)

% save country name
selectedData.selectedName = country;

% extract country
con = allData.confirmed(strcmp(allData.confirmed{:,2},country),:);
dea = allData.deaths   (strcmp(allData.deaths{:,2},   country),:);
rec = allData.recovered(strcmp(allData.recovered{:,2},country),:);

% extract data
selectedData.confirmed = sum(cellfun(@str2num, con{:,startDate:end}),1);
selectedData.deaths    = sum(cellfun(@str2num, dea{:,startDate:end}),1);
selectedData.recovered = sum(cellfun(@str2num, rec{:,startDate:end}),1);

% extract dates
selectedData.timeConfirmed = datetime(allData.confirmed{1,startDate:end}, 'InputFormat', 'MM/dd/yy');
selectedData.timeDeaths    = datetime(allData.deaths   {1,startDate:end}, 'InputFormat', 'MM/dd/yy');
selectedData.timeRecovered = datetime(allData.recovered{1,startDate:end}, 'InputFormat', 'MM/dd/yy');

end


function d = plotData(selectedData,country)
scale = 'log';

conf = selectedData.confirmed;
deat = selectedData.deaths;
reco = selectedData.recovered;
conftime = selectedData.timeConfirmed;
deattime = selectedData.timeDeaths;
recotime = selectedData.timeRecovered;
leng = min([length(conf),length(deat),length(reco)]);
infe = conf(1:leng) - deat(1:leng) -reco(1:leng);

subplot(3,3,1), hold on
plot(conftime,conf,'.','Markersize',15), ylabel('confirmed')
set(gca, 'YScale', scale)

subplot(3,3,2), hold on
plot(recotime,reco,'.','Markersize',15), ylabel('recovered')
xlabel('time $t$ [days]')
set(gca, 'YScale', scale)

subplot(3,3,3), hold on
plot(deattime,deat,'.','Markersize',15), ylabel('deaths')
xlabel('time $t$ [days]')
set(gca, 'YScale', scale)

subplot(3,3,4), hold on
plot(conftime(1:leng),infe,'.','Markersize',15), ylabel('active cases')
xlabel('time $t$ [days]')
set(gca, 'YScale', scale)

subplot(3,3,5), hold on
plot(conftime(2:end), 100*diff(conf)./conf(1:end-1),'.','Markersize',15), ylabel('% conf. increase (daily)')
set(gca, 'YScale', 'lin')
ylim([0 50])

subplot(3,3,6), hold on
plot(conftime,100*deat./conf,'.','Markersize',15), ylabel('% mort. rate')
xlabel('time $t$ [days]')
set(gca, 'YScale', 'lin')
% ylim([0 11])

subplot(3,3,7), hold on
plot(recotime(2:end),diff(reco),'.','Markersize',15), ylabel('newly recovered')
xlabel('time $t$ [days]')
set(gca, 'YScale', scale)

subplot(3,3,8), hold on
plot(conftime(2:end),diff(conf),'.','Markersize',15), ylabel('newly confirmed')
xlabel('time $t$ [days]')
set(gca, 'YScale', scale)

subplot(3,3,9), hold on
plot(deattime(2:end),diff(deat),'.','Markersize',15), ylabel('newly deaths')
xlabel('time $t$ [days]')
set(gca, 'YScale', scale)

% subplot(3,3,9), hold on
% plot(recotime(2:end),diff(conf)-diff(reco)-diff(deat),'.','Markersize',15), ylabel('newly conv-reco-death')
% xlabel('time $t$ [days]')
% set(gca, 'YScale', 'lin')

sgtitle('Covid-19 outbreak')
hLegend = findobj(gcf, 'Type', 'Legend');

warning off
if isempty(hLegend)
  legend(selectedData.selectedName);
else
  leg = {hLegend.String, selectedData.selectedName};
  hLegend.String{end} = selectedData.selectedName;
end
warning on

d.conftime = conftime;
d.deattime = deattime;
d.recotime = recotime;
d.conf = conf;
d.deat = deat;
d.reco = reco;

end