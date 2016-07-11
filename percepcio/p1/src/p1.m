%% Sistemes de Percepció: Pràctica 1
% 21739 - Percepció i Control per a Sistemes Encastats
% Grau en Enginyeria Informàtica

%% Presa de contacte (30 min)

%% 1. load image (imread)
img1 = imread('img/practica1_1.jpg');

%% 2. resize image (imresize)
img1_2  = imresize(img1, 1/2);
img1_4  = imresize(img1, 1/4);
img1_16 = imresize(img1, 1/16);

%% 3. save image (imwrite)
imwrite(img1_2, 'escalat1_2.jpg');
imwrite(img1_4, 'escalat1_4.jpg');
imwrite(img1_16,'escalat1_16.jpg');

%% 4. show images (figure, imshow, subplot)
figure
subplot(2,2,1); imshow(img1);    title('original');
subplot(2,2,2); imshow(img1_2);  title ('resized 1/2');
subplot(2,2,3); imshow(img1_4);  title ('resized 1/4');
subplot(2,2,4); imshow(img1_16); title ('resized 1/16');

print -dpng f_img1;

if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
close all;

%% 5. generate gray image (rgb2gray)
img1_gray = rgb2gray(img1);
imwrite(img1_gray, 'gray_1.jpg');

%% Millora d'imatge i eliminació del soroll (50min)

%% 1. load image (imread)
img2 = imread('img/practica1_2.jpg');

%% 2. show image histrogram (imhist)
figure
imhist(img2); title('histogram of "practica1\_2.jpg"');

if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
close all;

%% 3. improve contrast doing an histogram stretching (imadjust)
img2_adjust = imadjust(img2);

%% 4. show image histogram (imhist)
figure
imhist(img2_adjust); title('histogram of "practica1\_2.jpg" with stretching');

if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
close all;

%% 5. improve contrast doing an histogram equalization (histeq, cumsum)
img2_eq = histeq(img2);
[count, scale] = imhist(img2_eq);
accumulated = cumsum(count);
figure
plot(scale, accumulated); title('cumsum of equalized image');

print -dpng f_img2_eq_cumsum;

if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
close all;

%% 6. improve contrast using "Contrast-limited Adaptive Histogram Equalization" CLAHE (adapthisteq) 
img2_adapt = adapthisteq(img2);
[count, scale] = imhist(img2_adapt);
accumulated = cumsum(count);
figure
plot(scale, accumulated); title('cumsum of adapted image');

print -dpng f_img2_adapt_cumsum;

if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
close all;

%% 7. show images
figure
subplot(2,2,1); imshow(img2);        title('original');
subplot(2,2,2); imshow(img2_adjust); title('adjusted');
subplot(2,2,3); imshow(img2_eq);     title('equalized');
subplot(2,2,4); imshow(img2_adapt);  title('clahe');

print -dpng f_img2_all;

if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
close all;

%% 8. show histograms
figure
subplot(2,2,1); imhist(img2);        title('original');
subplot(2,2,2); imhist(img2_adjust); title('adjusted');
subplot(2,2,3); imhist(img2_eq);     title('equalized');
subplot(2,2,4); imhist(img2_adapt);  title('clahe');

print -dpng f_img2_hist_all;

if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
close all;

%% 9. load image (imread)
img3 = imread('img/practica1_3_gauss.jpg');

%% 10. noise filtering (conv2)
% gaussian filter of size = [3 3] and sigma (standard derivation) = 1
filter = fspecial('gaussian', [3 3], 1);
img_conv = uint8(conv2(double(img3), filter, 'same'));

%% 11. noise filtering (imfilter in convolution mode)
img_filter = imfilter(img3, filter, 'same', 'conv');

%% 12. noise filtering (medfilt2)
img_filt = medfilt2(img3);

%% 13. show images
figure
subplot(2,2,1); imshow(img3);       title('original');
subplot(2,2,2); imshow(img_conv);   title('conv2 gauss filter');
subplot(2,2,3); imshow(img_filter); title('imfilter gauss filter in convolution mode');
subplot(2,2,4); imshow(img_filt);   title('medfilt2 filter');

print -dpng f_img3_noise_filter_all;

if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
close all;

%% 14. repeat 9 to 13
img3_2 = imread('img/practica1_3_saltpepper.jpg');

% gaussian filter of size = [3 3] and sigma (standard derivation) = 1
filter = fspecial('gaussian', [3 3], 1);
img_conv = uint8(conv2(double(img3_2), filter, 'same'));

img_filter = imfilter(img3_2, filter, 'same', 'conv');

img_filt = medfilt2(img3_2);

figure
subplot(2,2,1); imshow(img3_2);     title('original');
subplot(2,2,2); imshow(img_conv);   title('conv2 gauss filter');
subplot(2,2,3); imshow(img_filter); title('imfilter gauss filter in convolution mode');
subplot(2,2,4); imshow(img_filt);   title('medfilt2 filter');

print -dpng f_img3_2_noise_filter_all;

if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
close all;

%% Binarització d’imatges (20 min)

%% generate binary image (im2bw, graythresh, imshow)
colour_level = [0.2 0.5 0.7];
for i = 4:7
    img = imread(sprintf('img/practica1_%d.jpg', i));
    colour_level(4) = graythresh(img);
    f = figure;
    for j = 1:size(colour_level, 2)
        bw_img = im2bw(img, colour_level(j));
        subplot(2, 2, j);
        imshow(bw_img);
        title(sprintf('binary level %.3f', colour_level(j)));
    end
    print(f, sprintf('binary_all_%d', i), '-dpng');
end

if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
close all;

%% Extracció de contorns (20 min)

%% generate edge image (edge)
edge_algh = {'sobel','canny','log'};
for i = 4:7
    img = imread(sprintf('img/practica1_%d.jpg', i));
    f = figure;
    subplot(2,2,1); imshow(img); title('original');
    for j = 1:numel(edge_algh)
    	algh = edge_algh{j};
    	subplot(2,2,j+1);
    	edge(img, algh);
    	title(algh);
    end
    print(f, sprintf('edge_all_%d', i), '-dpng');
end

if strcmpi(Util.defaultQuestion(), 'no'); close all; return; end;
close all;
