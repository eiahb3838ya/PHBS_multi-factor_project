function v = parseStringToStructPath(obj, S, fieldlist)
% PARSESTRINGTOSTRUCTPATH is a util function that parse string to dynamic
% struct path. 

  fn = regexp(fieldlist, '\.', 'split');
  bad_fields = fn(cellfun(@isempty,regexp(fn, '^[A-Za-z][A-Za-z0-9_]*$')));
  if ~isempty(bad_fields)
     error('Only plain fieldnames are allowed. First invalid one is "%s"', bad_fields{1});
  end
  v = S;
  for K = 1 : length(fn)
     thisfn = fn{K};
     if isfield(v, thisfn)
       if length(v) == 1
         v = v.(thisfn);
       else
         error('MATLAB:dotRefOnNonScalar', 'Dot name reference on non-scalar structure. Field "%s"', strjoin(fn(1:K), '.'));
       end
     else
       error('Field "%s" does not exist in structure', strjoin(fn(1:K), '.'));
     end
  end
end
