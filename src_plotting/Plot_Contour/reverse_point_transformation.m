punkt = [-21.57 2.72 2239.54];

punktVorRot2 = (matrixRotation2' * punkt')'

punktVorRot2(3) = -(punktVorRot2(3) - 3524.1)

punktVorRot1 = (matrixRotation' * punktVorRot2')'