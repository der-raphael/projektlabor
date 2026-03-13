point_trans = [-21.57 2.72 2239.54];

ReversePointTransformation(point_trans);

function point = ReversePointTransformation(point_trans)
    pointBeforeRot2 = (matrixRotation2' * point_trans')';
    pointBeforeRot2(3) = -(pointBeforeRot2(3) - 3524.1);
    pointBeforeRot1 = (matrixRotation' * pointBeforeRot2')';
    point = pointBeforeRot1;
end
