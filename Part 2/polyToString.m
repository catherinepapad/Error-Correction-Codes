function poly_string = polyToString(poly)
    % Create a string for the polynomial in the form 1 + x^a + x^b + ...
    poly_string = sprintf('%dx^{%d}', poly(find(poly, 1)), find(poly, 1));
    for i = find(poly, 1)+1:length(poly)
        if poly(i) == 0
            continue
        end
        poly_string = strcat(poly_string, sprintf(' + %dx^{%d}', poly(i), i));
    end
end