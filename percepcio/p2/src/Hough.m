classdef Hough
    % Hough class
    % Contains the Hough Transform algorithm v2 and common functions.
    methods(Static)
        
        %% hough() function
        % Implements the Hough Transform Algorithm v2
        % @params
        % imgEdges: edges image
        % rho: rho increment
        % theta: theta increment (rad)
        % @return
        % H: Hough accumulator
        % theta: theta vector
        % rho: rho vector
        function [H,theta,rho] = hough(imgEdges, rhoIncrement, thetaIncrement)
            % define the Hough space
            diagonal = norm(size(imgEdges));
            rho = -diagonal:rhoIncrement:diagonal;
            thetaLimit = degtorad(10);
            theta = -thetaLimit:thetaIncrement:thetaLimit;

            % define the Hough accumulator
            p = numel(theta);
            q = numel(rho);
            H = zeros(q,p);

            % find the 'edge' pixels (col, row)
            [v,u] = find(imgEdges);
            % for each edge
            for r = 1:numel(u)
                % for theta increments
                for th = theta
                    % determine the nearest rho
                    pk = Hough.nearestRho(u(r)*cos(th) + v(r)*sin(th), rho);
                    % cast to int to delete the possible double/float format
                    s = uint16(((th+thetaLimit)/thetaIncrement)+1);
                    t = uint16(((pk+diagonal)/rhoIncrement)+1);
                    H(t,s) = H(t,s) + 1;
                end
            end
        end

        %% nearestRho() function
        % Return the nearest rho in rho vector
        % @params
        % value: value to find the nearest rho
        % rho: rho vector
        function nearest = nearestRho(value, rho)
            diff = abs(rho-value);
            [~,I] = min(diff);
            nearest = rho(I);
        end

        %% print() function
        % Show Hough accumulator representation
        % @params
        % H: Hough accumulator
        % theta: theta vector
        % rho: rho vector
        % @return
        % f: figure
        function f = print(H, theta, rho)
            f = figure;
            imagesc(theta,rho,H);
            title('Hough transform'); xlabel('\theta'); ylabel('\rho');
        end

        %% printLines() function
        % Print vertial lines detected on the original image
        % @params
        % H: Hough accumulator
        % theta: theta vector
        % rho: rho vector
        % nLines: number of lines to print
        % img: original image
        % @return
        % f: figure
        function f = printLines(H, theta, rho, nLines, img)
            f = figure;
            imshow(img); title('line detection');
            height = size(img,1);
            for n = 1:nLines
                % get Hough accumnulator max. value
                [~, index] = max(H(:));
                [y, x] = ind2sub(size(H), index);

                % undo calc and get the original pixel
                th = theta(x);
                r = rho(y);
                u = (r-sin(th))/cos(th);

                % print vertical line on the original image
                hold on;
                X=[u u]; Y=[1 height]; plot(X, Y, 'LineWidth', 2);
                hold off;

                % clear max. value & surronded matrix
                coord1 = [x-1 y-4]; coord2 = [x+1 y+4];
                if coord1(1)<1; coord1(1)=1; end;
                if coord1(2)<1; coord1(2)=1; end;
                if coord2(1)>numel(theta); coord2(1)=numel(theta); end;
                if coord2(2)>numel(rho); coord2(2)=numel(rho); end;
                H(coord1(2):coord2(2),coord1(1):coord2(1))=0;                
            end
        end

    end
end
