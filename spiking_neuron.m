clearvars();

% パラメータ設定
C = 1; I = 40; EL = -78; gL = 8; gNa = 20; gK = 10;
V12m = -20; km = 15; V12n = -45; kn = 5;
tau = 1; ENa = 60; EK = -90;

% 関数定義
minf = @(V) 1./(1 + exp((V12m - V)./km));
ninf = @(V) 1./(1 + exp((V12n - V)./kn));

dVdt = @(V, n) (I - gL*(V - EL) - gNa*minf(V).*(V - ENa) - gK*n.*(V - EK)) / C;
dndt = @(V, n) (ninf(V) - n) / tau;

% シミュレーション設定
dt = 0.01; % タイムステップ
T = 30;  % シミュレーション時間
time = 0:dt:T;

% 初期値 - I = 0のときの定常値
V0 = -60.8648; n0 = 0.040196;

% 初期値ベクトル
initial_state = [V0, n0];

% 数値積分 (Euler法)
V = zeros(size(time));
n = zeros(size(time));
V(1) = V0;
n(1) = n0;

for i = 1:length(time)-1
    V(i+1) = V(i) + dt * dVdt(V(i), n(i));
    n(i+1) = n(i) + dt * dndt(V(i), n(i));
end

% Nullcline計算
V_null = linspace(-90, 40, 200); % Vの範囲
n_null_V = zeros(size(V_null));
n_null_n = ninf(V_null);

for i = 1:length(V_null)
    n_null_V(i) = (I - gL*(V_null(i) - EL) - gNa*minf(V_null(i)).*(V_null(i) - ENa)) / (gK*(V_null(i) - EK));
end

% Flow Field計算
V_flow = linspace(-90, 40, 20);
n_flow = linspace(0, 1, 20);
[VV, NN] = meshgrid(V_flow, n_flow);
dV = dVdt(VV, NN);
dN = dndt(VV, NN);

% Nullclineの交点計算
%  fsolve関数を使って交点を求める
% まずはnullclineを定義する。
nullcline_v = @(x) (I - gL*(x(1) - EL) - gNa*minf(x(1)).*(x(1) - ENa)) / (gK*(x(1) - EK)) - x(2);
nullcline_n = @(x) ninf(x(1)) - x(2);
% 2つのnullclineの交点を求める関数を定義
f = @(x) [nullcline_v(x); nullcline_n(x)];

% 初期値の設定 (目安としてnullclineの交点付近の値)
initial_guess = [-50; 0.2];
% fsolve関数で解を求める
options = optimoptions('fsolve','Display','off'); % 計算過程を表示しない
intersection = fsolve(f, initial_guess, options);
% 結果を表示
disp(['Nullclineの交点: V = ', num2str(intersection(1)), ', n = ', num2str(intersection(2))]);

%%
f1 = 10;
sel = (dV < -200 & VV > -10);

fig = figure();
fig.PaperOrientation = 'landscape';
fig.PaperPosition = [0.6345 0.6345 28.4310 19.7310];

% flow field
subplot(2,1,1)
axis square
axis([-90 20 0 0.75])
hold on
custom_quiver(VV(~sel), NN(~sel), dV(~sel), dN(~sel), 'Color', [0.7 0.7 0.7], 'Scale', 0.05, 'ArrowScale', 0.01, 'ArrowheadAngle', 45); % Flow Field
custom_quiver(VV(sel), NN(sel), dV(sel), dN(sel), 'Color', [0.9 0.9 0.9], 'Scale', 0.02, 'ArrowScale', 0.01, 'ArrowheadAngle', 45); % Flow Field
plot(V_null, n_null_V, 'r', 'LineWidth', 2, 'DisplayName', 'V Nullcline'); % V Nullcline
plot(V_null, n_null_n, 'b', 'LineWidth', 2, 'DisplayName', 'n Nullcline'); % n Nullcline
plot(V, n, 'k', 'LineWidth', 1, 'DisplayName', 'Trajectory'); % Limit Cycle
plot(intersection(1), intersection(2), 'go', 'MarkerSize', 8, 'MarkerFaceColor', 'g', 'DisplayName', 'Intersection'); % Nullclineの交点

% Vの時間発展
subplot(2, 1, 2);
plot(time, V, 'b', 'LineWidth', 1);
xlabel('Time (ms)'); ylabel('V (mV)'); title('V vs. Time');
axis([0 T -80 0]);
axis square
