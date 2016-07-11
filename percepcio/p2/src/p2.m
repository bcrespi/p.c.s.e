%% Sistemes de Percepció: Pràctica 2
% 21739 - Percepció i Control per a Sistemes Encastats
% Grau en Enginyeria Informàtica

%% Detecció de contorns verticals de les portes

%% 1. Extracció de contorns
%  2. Implementació de la Transformada de Hough
%  3. Selecció de les N columnes

edge_algh = {'sobel','prewitt','roberts','log','zerocross','canny'};

for file = dir('img/*.jpg')'
    img = imread(strcat('img/', file.name));
    img_gray = rgb2gray(img);
    f = figure;
    for i = 1:numel(edge_algh)
        algh = edge_algh{i};
        subplot(3,2,i); edge(img_gray, algh); title(algh);
    end
    filename = file.name(1:strfind(file.name, '.') - 1);
    print(f, strcat(filename, '_edges'), '-dpng');
end

if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
close all;

%% After try with all algorithms we decide that 'sobel' is better.

for file = dir('img/*.jpg')'
    filename = file.name(1:strfind(file.name, '.') - 1);
    
    img = imread(strcat('img/', file.name));
    img_gray = rgb2gray(img);
    img_edges = edge(img_gray, 'sobel', 0.1, 'vertical');

    % Hought Transform algorithm v2
    [H,theta,rho] = Hough.hough(img_edges, 1, degtorad(1));

    % Show Hough accumulator representation
    f = Hough.print(H, theta, rho);
    print(f, strcat(filename, '_hought'), '-dpng');
    
    % Show vertical lines detection
    f = Hough.printLines(H, theta, rho, 6, img);
    print(f, strcat(filename, '_line_detection'), '-dpng');
    
    if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
    close all;
end
