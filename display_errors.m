function lengthToErase = display_errors(errors)

s = sprintf('%d',errors);
preamb = 'Current errors: ';

fprintf('%s %s', preamb, s);

lengthToErase = 1 + length(s) + length(preamb);