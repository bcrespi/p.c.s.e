classdef Perceptron
    % Perceptron class
    % contains the Perceptron algorithm v2 (bag) and common functions.
    methods(Static)
        
        %% classifySamples() function
        % Implements the samples classification for the Perceptron algorithm
        % @params
        % trainning: data with the trainning values
        % data: modified trainning for classify the values
        % height: number of trainning elements
        % w: ranking/separator plane
        % rho: convergence speed
        % @return
        % hits: hits of data classified correctly
        % sum: ranking/separator plane accumulator
        function [hits, sum] = classifySamples(trainning, data, height, w, rho)
            hits = height;          % max. hits
            sum =  zeros(1,4);      % omega
            % no. samples correctly classified
            for i = 1:height
                xi = data(i,:);
                if w*xi' < 0 && trainning(i,4) == 1
                    sum = sum + rho*xi;
                    hits = hits - 1;
                elseif w*xi' > 0 && trainning(i,4) == 2
                    sum = sum - rho*xi;
                    hits = hits - 1;
                end 
            end
        end
        
        %% hyperplane() function
        % Return the hyperplane that separes the data in categories
        % @params
        % trainning: data with the trainning values
        % rho: convergence speed
        % T: number of iterations
        % @return
        % ws: hyperplane
        function ws = hyperplane(trainning, rho, T)            
            % initialize w randomly
            w = rand(1,4);
            ws = w;
            height = size(trainning, 1); % data size
            data = [trainning(:,1:3) ones(height, 1)];
            % no. samples correctly classified by w(0)
            [hs, ~] = Perceptron.classifySamples(trainning, data, height, w, rho);
            for t = 1:T
                % no. samples correctly classified by w(t+1)
                [h, sum] = Perceptron.classifySamples(trainning, data, height, w, rho);
                w = w + sum;
                if h > hs
                    ws = w;
                    hs = h;
                end
            end
        end
        
    end
end

