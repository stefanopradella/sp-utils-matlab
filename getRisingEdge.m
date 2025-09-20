function y = getRisingEdge(x)
    arguments
        x (:, 1) logical
    end

    y = [false; diff(x) == 1];
end