x = 3;
y = 0;

while y || x > 0
    x = x - 1;
    y = y + x;
end

disp(['Final value of x: ', num2str(x)]);