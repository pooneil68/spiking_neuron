function custom_quiver(x, y, u, v, varargin)
% custom_quiver(x, y, u, v, ...)
%
% MATLABのquiver関数を再現し、矢印のサイズを調整する機能を追加
%
% 入力:
%   x, y: 矢印の始点の座標
%   u, v: 矢印の方向ベクトル
%   varargin: その他のオプション (例: 'Color', 'r', 'LineWidth', 2)
%             'Scale': 矢印全体の長さを調整する係数 (デフォルト: 1)
%             'ArrowScale': 矢印ヘッドのサイズを調整する係数 (デフォルト: 1)
%             'ArrowheadAngle': 矢印ヘッドの角度 (度)

% デフォルト値
scale = 1;
arrowScale = 1;
color = 'b';  % デフォルトの色を青に
lineWidth = 1;
arrowhead_ratio = 0.3;  % 矢印ヘッドの長さの比率
arrowhead_angle = 30;   % 矢印ヘッドの角度 (度)

% オプションの解析
i = 1;
while i <= length(varargin)
    if strcmpi(varargin{i}, 'Scale')
        scale = varargin{i+1};
        i = i + 2;
    elseif strcmpi(varargin{i}, 'ArrowScale')
        arrowScale = varargin{i+1};
        i = i + 2;
    elseif strcmpi(varargin{i}, 'Color')
        color = varargin{i+1};
        i = i + 2;
    elseif strcmpi(varargin{i}, 'LineWidth')
        lineWidth = varargin{i+1};
        i = i + 2;
    elseif strcmpi(varargin{i}, 'ArrowheadAngle')  % ArrowheadAngleオプションを追加
        arrowhead_angle = varargin{i+1};
        i = i + 2;
    else
        error('Unknown option: %s', varargin{i});
    end
end

% 現在の軸の情報を取得
ax = gca;
x_lim = xlim(ax);
y_lim = ylim(ax);
x_range = diff(x_lim);
y_range = diff(y_lim);
pbaspect_ratio = pbaspect(ax); %Plot Box Aspect Ratio

for i = 1:length(x)
    % スケールを適用
    uu = u(i) * scale;
    vv = v(i) * scale;

    % 矢印の終点
    x2 = x(i) + uu;
    y2 = y(i) + vv;

    % 軸のスケールとアスペクト比を考慮した方向ベクトルの計算
    dx = uu / x_range;
    dy = vv / y_range;

    % 矢印ヘッドの計算
    arrow_length = sqrt(dx^2 + dy^2) * arrowhead_ratio * arrowScale * max(x_range, y_range); % scaleを適用しない

    if arrow_length == 0 % u, v = 0 の場合例外処理
        continue
    end

    % 正規化された方向ベクトル
    norm_dx = dx / sqrt(dx^2 + dy^2);
    norm_dy = dy / sqrt(dx^2 + dy^2);

    % 角度をラジアンに変換
    angle_rad = arrowhead_angle * pi / 180;

    % 矢印ヘッドの2つの点の計算 (回転行列を使用)
    x3 = x2 + arrow_length * (-norm_dx * cos(angle_rad) + norm_dy * sin(angle_rad)) * x_range;
    y3 = y2 + arrow_length * (-norm_dx * sin(angle_rad) - norm_dy * cos(angle_rad)) * y_range;
    x4 = x2 + arrow_length * (-norm_dx * cos(-angle_rad) + norm_dy * sin(-angle_rad)) * x_range;
    y4 = y2 + arrow_length * (-norm_dx * sin(-angle_rad) - norm_dy * cos(-angle_rad)) * y_range;

    % 線の描画 (矢印の軸)
    line([x(i), x2], [y(i), y2], 'Color', color, 'LineWidth', lineWidth);

    % 矢印ヘッドの描画
    line([x2, x3], [y2, y3], 'Color', color, 'LineWidth', lineWidth);
    line([x2, x4], [y2, y4], 'Color', color, 'LineWidth', lineWidth);
end
end