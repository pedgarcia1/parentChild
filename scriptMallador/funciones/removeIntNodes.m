function nodesSinInt = removeIntNodes(nodesFisuIndex,nodesIntIndex)
%%Modifica el vector de nodosFisu para sacar las intersecciones.

    nodesIntLogical = ismember(nodesFisuIndex,nodesIntIndex);
    nodesFisuIndex(nodesIntLogical) = [];
    nodesSinInt = nodesFisuIndex;
end
