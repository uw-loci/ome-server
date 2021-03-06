%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Copyright (C) 2005 Open Microscopy Environment
%       Massachusetts Institue of Technology,
%       National Institutes of Health,
%       University of Dundee
%
%
%
%    This library is free software; you can redistribute it and/or
%    modify it under the terms of the GNU Lesser General Public
%    License as published by the Free Software Foundation; either
%    version 2.1 of the License, or (at your option) any later version.
%
%    This library is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%    Lesser General Public License for more details.
%
%    You should have received a copy of the GNU Lesser General Public
%    License along with this library; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Written By: Tom Macura <tmacura@nih.gov>
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function score = ConfusionMatrixScore(conf_mat, penalty_mat);
% INPUTS NEEDED:
%   'conf_mat'      - confusion matrix
%   'penalty_mat'   - penalty matrix (optional). This should have zeros on diag
% OUTPUTS GIVEN:
%   'score'         - scalar summarizing the confusion matrix 
%
% Tom Macura - 2005. tm289@cam.ac.uk

if (nargin < 2)
	[r,c] = size(conf_mat);
	penalty_mat = zeros(r,c);
end

[r,c] = size(conf_mat);
[r_p,c_p] = size(penalty_mat);

if (r ~= r_p || c ~= c_p)
	error('conf_mat and penalty_mat do not have same dimensions');
end

conf_mat = conf_mat + penalty_mat .* conf_mat;
score = sum(diag(conf_mat)) / sum(sum(conf_mat));