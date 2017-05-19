GRADIENT_HORIZONTAL = 0;
GRADIENT_VERTICAL = 1;
function draw.LinearGradient(x,y,w,h,from,to,dir,res)
    dir = dir or GRADIENT_HORIZONTAL;
    if dir == GRADIENT_HORIZONTAL then res = (res and res <= w) and res or w;
    elseif dir == GRADIENT_VERTICAL then res = (res and res <= h) and res or h; end
    for i=1,res do
        surface.SetDrawColor(
            Lerp(i/res,from.r,to.r),
            Lerp(i/res,from.g,to.g),
            Lerp(i/res,from.b,to.b),
            Lerp(i/res,from.a,to.a)
        );
        if dir == GRADIENT_HORIZONTAL then surface.DrawRect(x + w * (i/res), y, w/res, h );
        elseif dir == GRADIENT_VERTICAL then surface.DrawRect(x, y + h * (i/res), w, h/res ); end
    end
end