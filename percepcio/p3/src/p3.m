DOOR_PATH = 'img/patches/door/';
WALL_PATH = 'img/patches/wall/';

DOOR_CLASS = 1;
WALL_CLASS = 2;

doorFiles = dir(strcat(DOOR_PATH, '*.jpg'));
wallFiles = dir(strcat(WALL_PATH, '*.jpg'));
doorNumel = numel(doorFiles);
wallNumel = numel(wallFiles);

% | saturation | energy | entropy | class |
trainning = zeros(doorNumel + wallNumel, 4);
[energy, entropy] = deal(0);

for i = 1:doorNumel
    % load images
    img = imread(strcat(DOOR_PATH, doorFiles(i).name));
    imgHSV = rgb2hsv(img);
    imgGray = rgb2gray(img);
    % by default 8 gray levels
    imgGLCM = graycomatrix(imgGray);
    
    % calculate values
    saturation = mean2(imgHSV(:,:,2));
    [energy, entropy] = deal(0);
    probability = sum(imgGLCM(:));
    
    % matrix to vector M(:)'
    for value = imgGLCM(:)';
        if value ~= 0
            energy = energy + (value/probability)^2;
            entropy = entropy + ((value/probability)*(log2(value/probability)));
        end
    end
    
    % add to training
    trainning(i,1) = saturation;
    trainning(i,2) = energy;
    trainning(i,3) = -entropy;
    trainning(i,4) = DOOR_CLASS;
end

for i = 1:wallNumel
    % load images
    img = imread(strcat(WALL_PATH, wallFiles(i).name));
    imgHSV = rgb2hsv(img);
    imgGray = rgb2gray(img);
    % by default 8 gray levels
    imgGLCM = graycomatrix(imgGray);

    % calculate values
    saturation = mean2(imgHSV(:,:,2));
    [energy, entropy] = deal(0);
    probability = sum(imgGLCM(:));

    % matrix to vector M(:)'
    for value = imgGLCM(:)';
        if value ~= 0
            energy = energy + (value/probability)^2;
            entropy = entropy + ((value/probability)*log2(value/probability));
        end
    end
    
    % add to training
    trainning(doorNumel+i,1) = saturation;
    trainning(doorNumel+i,2) = energy;
    trainning(doorNumel+i,3) = -entropy;
    trainning(doorNumel+i,4) = WALL_CLASS;
end

disp('trainning data loaded.');

% Perceptron
disp('starting Perceptron.hyperplane.');
ws = Perceptron.hyperplane(trainning, 1, 100);
disp('finished Perceptron.hyperplane.');

 % scatter3 color matrix in rgb
plotColors = zeros(size(trainning, 1), 3);
for p = 1:size(trainning, 1)
    if trainning(p,4) == 1
        plotColors(p,1:3) = [0 0 255];
    else
        plotColors(p,1:3) = [0 255 0];
    end
end
f = figure;
sc = scatter3(trainning(:, 1), trainning(:, 2), trainning(:, 3),...
    36, plotColors, 'filled', 'MarkerEdgeColor', 'k');

[xx,yy]=ndgrid(0:1,0:1);
z = (-ws(1)*xx - ws(2)*yy - ws(4))/ws(3);
hold on;
surf(xx,yy,z);
hold off;

print(f, 'hyperplane', '-dpng');

for file = dir('img/*.jpg')'
    filename = file.name(1:strfind(file.name, '.') - 1);

    fprintf('[%s] starting classification.\n', file.name);

    img = imread(strcat('img/', file.name));
    img_gray = rgb2gray(img);
    img_edges = edge(img_gray, 'sobel', 0.1, 'vertical');

    fprintf('[%s] starting Hough Tranform to vertical line detection.\n', file.name);
    [H,T,R] = hough(img_edges);
    P = houghpeaks(H,10);
    lines = houghlines(img_edges, T, R, P);
    
    f2 = figure;
    imshow(img);
    hold on
    
    x_diff = 30;
    [height, width, ~] = size(img);
    x_values = java.util.ArrayList();
    rho_values = java.util.ArrayList();
    
    X=[lines(1).point1(1) lines(1).point1(1)]; Y=[1 height];
    plot(X,Y,'LineWidth',2,'Color','green');

    % Add values
    x_values.add(lines(1).point1(1));
    rho_values.add(lines(1).rho);
    k = 2;
    while k <= length(lines)
        % Check values
        paint = true;
        for c = 0:x_values.size()-1
            if lines(k).rho == rho_values.get(c) ||...
                    abs(lines(k).point1(1) - x_values.get(c)) < x_diff
            paint = false;
            end
        end
        if paint
            X=[lines(k).point1(1) lines(k).point1(1)]; Y=[1 height];
            plot(X,Y,'LineWidth',2,'Color','green');
            
            % Add values
            x_values.add(lines(k).point1(1));
            rho_values.add(lines(k).rho);
        end
        k = k + 1;
    end
    hold off
    fprintf('[%s] line detection finished.\n', file.name);
    print(f2, strcat(filename, '_hough_line_detection'), '-dpng');

    % x_values contains the 'x' to separete zones
    % add to ArrayList start x = 0 and end x = height
    x_values.add(0, 1); x_values.add(width);
    java.util.Collections.sort(x_values);
    
    fprintf('[%s] stating segments classification 30x30.\n', file.name);
    segment_classification = zeros(1, x_values.size()-1);
    
    for i = 0:x_values.size()-2
        x1 = x_values.get(i);
        x2 = x_values.get(i+1);
        
        % segment image in 30x30
        n_vertical = floor((x2-x1)/30);
        n_horizontal = floor(height/30);
        
        n_total = n_vertical * n_horizontal;
        fprintf('[%s] segments classification [%d]: %d subimages.\n', file.name, i+1, n_total);
        [door_detection, wall_detection] = deal(0);
        
        f3 = figure;
        idx = 1;
        
        YY = [1 0];
        for j = 1:n_horizontal
            XX = [x1 x1-1];
            YY(2)=YY(2)+30;
            for k = 1:n_vertical
                XX(2)=XX(2)+30;
                
                img_tmp = img(YY(1):YY(2),XX(1):XX(2),:);
                subplot(n_horizontal,n_vertical,idx); imshow(img_tmp);
                
                img_hsv = rgb2hsv(img_tmp);
                img_gray = rgb2gray(img_tmp);
                % by default 8 gray levels
                img_glcm = graycomatrix(img_gray);

                % calculate values
                saturation = mean2(img_hsv(:,:,2));
                [energy, entropy] = deal(0);
                probability = sum(img_glcm(:));
                
                for value = img_glcm(:)';
                    if value ~= 0
                        energy = energy + (value/probability)^2;
                        entropy = entropy + ((value/probability)*log2(value/probability));
                    end
                end
                % | saturation | energy | entropy |
                values = [saturation energy -entropy 1];
                if ws*values' > 0
                    door_detection = door_detection + 1;
                else
                    wall_detection = wall_detection + 1;
                end                
                XX(1)=XX(1)+30;
                idx = idx + 1;
            end
            YY(1)=YY(1)+30;
        end

        fprintf('[%s] segments classification [%d] finished.\n', file.name, i+1);
        
        if door_detection/n_total > 0.6
            % door segment
            segment_classification(i+1)=DOOR_CLASS;
            fprintf('[%s] segments classified [%d] as door (%.3f%%).\n', file.name, i+1, door_detection/n_total*100);
            print(f3, strcat(filename, '_segment_door'), '-dpng');
        elseif wall_detection/n_total > 0.6
            % wall segment
            segment_classification(i+1)=WALL_CLASS;
            fprintf('[%s] segments classified [%d] as wall (%.3f%%).\n', file.name, i+1, wall_detection/n_total*100);
            print(f3, strcat(filename, '_segment_wall'), '-dpng');
        else
            % undefined
            segment_classification(i+1)=-1;
            fprintf('[%s] segments classified [%d] as undefined.\n', file.name, i+1);
            print(f3, strcat(filename, '_segment_undefined'), '-dpng');
        end
    end
    
    fprintf('[%s] painting final image.\n', file.name);

    % paint original image wall and undefined zones
    imgf = img;
    for s = 1:numel(segment_classification)
        cYY = [1 height];
        cXX = [x_values.get(s-1) x_values.get(s)];
        if segment_classification(s) == WALL_CLASS
            imgf(cYY(1):cYY(2),cXX(1):cXX(2),:) = 0;
        elseif segment_classification(s) == -1
            imgf(cYY(1):cYY(2),cXX(1):cXX(2),:) = 255;
        end
    end

    f = figure;
    imshow(imgf); 
    print(f, strcat(filename, '_result'), '-dpng');
    
    close all;
end
