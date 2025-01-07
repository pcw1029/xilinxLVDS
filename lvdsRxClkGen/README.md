# lvdsRxClkGen 

## MMCME3_BASE 

`MMCME3_BASE`는 Xilinx FPGA에서 사용하는 Clock Management Tile (CMT)의 하나로, 복잡한 클럭 신호 처리 및 제어를 지원하는 MMCM (Mixed-Mode Clock Manager) 컴포넌트입니다. 주로 클럭 생성, 위상 조정, 주파수 변경 등을 수행하는 데 사용됩니다.



### **MMCME3_BASE의 주요 기능**

- **클럭 생성**: 입력 클럭 신호를 기준으로 원하는 주파수의 출력 클럭을 생성합니다.
- **주파수 곱셈/나눗셈**: 입력 클럭을 곱하거나 나눠 다양한 주파수의 출력 클럭을 제공합니다.
- **위상 조정**: 출력 클럭의 위상을 입력 클럭에 대해 정밀하게 조정합니다.
- **복수의 출력**: 다양한 출력 주파수와 위상을 가진 다중 클럭 신호를 생성할 수 있습니다.
- **정밀한 제어**: 내부에 PLL(Phase-Locked Loop) 또는 DLL(Delay-Locked Loop)을 사용해 안정적이고 정밀한 클럭 신호를 유지합니다.



### MMCME3_BASE의 포트

#### **입력 포트**

- `CLKIN1`: 입력 클럭 신호.
- `RST`: MMCM을 리셋하는 신호.
- `CLKFBIN`: 피드백 클럭 입력. 출력 클럭을 안정화하기 위해 내부 PLL에서 사용.

#### **출력 포트**

- `CLKFBOUT`: 피드백 클럭 출력. `CLKFBIN`과 연결되어 피드백 루프를 형성.
- `CLKOUT[0-6]`: 원하는 주파수와 위상을 가진 출력 클럭 신호.
- `LOCKED`: MMCM이 안정적으로 동작하는지 표시하는 상태 신호.



### 코드의 주요 설정

```verilog
MMCME3_BASE # (
    .CLKIN1_PERIOD      (CLKIN_PERIOD),  // 입력 클럭의 주기 (나노초 단위)
    .BANDWIDTH          ("OPTIMIZED"),   // 대역폭 모드 ("OPTIMIZED", "HIGH", "LOW")
    .CLKFBOUT_MULT_F    (4*VCO_MULTIPLIER), // 내부 PLL의 곱셈 계수
    .CLKFBOUT_PHASE     (0.0),           // 출력 클럭의 위상 (기본값 0.0도)
    .CLKOUT0_DIVIDE_F   (2*VCO_MULTIPLIER), // CLKOUT0의 나눗셈 계수
    .CLKOUT0_DUTY_CYCLE (0.5),           // CLKOUT0의 듀티 사이클 (50%)
    .CLKOUT0_PHASE      (0.0),           // CLKOUT0의 위상 (0도)
    .DIVCLK_DIVIDE      (1),             // 전체 클럭 나눗셈 계수
    .REF_JITTER1        (0.100)          // 입력 클럭의 지터 허용치 (100ps)
) rx_mmcm_adv_inst (
    .CLKFBOUT       (px_pllmmcm),        // 피드백 클럭 출력
    .CLKOUT0        (rx_pllmmcm_div2),   // 나뉜 클럭 출력 (rx_clkdiv2)
    .LOCKED         (cmt_locked),        // PLL 잠금 상태
    .CLKFBIN        (px_clk),            // 피드백 클럭 입력
    .CLKIN1         (clkin_p_i),         // 입력 클럭 신호
    .PWRDWN         (1'b0),              // 전원 차단 신호 비활성화
    .RST            (reset)              // 리셋 신호
);
```

1. **`CLKIN1_PERIOD`**: 입력 클럭 신호의 주기를 나노초 단위로 지정합니다.
   - 예: 12.5ns는 약 80MHz의 입력 클럭을 의미합니다.
2. **`CLKFBOUT_MULT_F`**: 내부 PLL에서 사용하는 곱셈 계수입니다.
   - 출력 주파수는 `입력 주파수 × CLKFBOUT_MULT_F`로 계산됩니다.
   - `VCO_MULTIPLIER` 값에 따라 동적으로 설정됩니다.
3. **`CLKOUT0_DIVIDE_F`**: 출력 클럭의 나눗셈 계수입니다.
   - 최종 출력 주파수는 `VCO 주파수 ÷ CLKOUT0_DIVIDE_F`로 계산됩니다.
4. **`LOCKED` 신호**: PLL/MMCM이 입력 클럭과 동기화되었는지 확인하는 출력 신호로, 안정적으로 동작하는지 나타냅니다.
5. **피드백 루프**: `CLKFBOUT`과 `CLKFBIN`을 연결하여 안정적인 클럭 동작을 유지합니다.

주의해야할점은 FPGA 내부 VCO (Voltage-Controlled Oscillator)가 안정적으로 동작할 수 있는 주파수 범위를 선택해야 한다. VCO는 특정 주파수 범위(예: 600MHz ~ 1200MHz)에서만 안정적으로 동작할 수 있으므로, 입력 클럭 주파수와 곱셈 계수를 조합하여 VCO를 이 범위 안에 맞춰야 합니다.

따라서 아래 코드와 같이 VCO_MULTIPLIER는 입력 클럭 주파수 주기가 150MHz보다 낮은 경우 아래와 같은 코드를 사용함으로서 VCO 주파수 범위를 맞춰 준다.

```verilog
localparam VCO_MULTIPLIER = (CLKIN_PERIOD > 6.667) ? 2 : 1;
```



## IDELAYE3

Xilinx의 **IDELAYE3** 블록을 이용해 입력 클럭 신호에 지연(delay)을 추가하거나 조정하는 역할을 합니다. 이를 통해 데이터 정렬, 타이밍 조정, 및 입력 클럭의 비트 시간(bit time)을 결정하는 데 사용됩니다.

### IDELAYE3의 주요 기능

* **지연 조정**: 입력 신호에 정밀한 지연을 추가하여 타이밍 제어를 수행합니다.

- **가변 지연 지원**: 외부 제어 신호로 지연 값을 설정할 수 있습니다.
- **참조 클럭 기반 동작**: 고정밀 지연을 위해 참조 클럭(REFCLK)을 사용합니다.

```verilog
IDELAYE3 # (
    .DELAY_SRC        ("IDATAIN"),        // 지연 소스: 입력 데이터(IDATAIN)
    .CASCADE          ("NONE"),           // 캐스케이드 설정: 단일 모드로 설정
    .DELAY_TYPE       ("VAR_LOAD"),       // 지연 타입: 가변 지연 (VAR_LOAD)
    .DELAY_VALUE      (DELAY_VALUE),      // 초기 지연 값: `DELAY_VALUE`
    .REFCLK_FREQUENCY (REF_FREQ),         // 참조 클럭 주파수
    .DELAY_FORMAT     ("TIME"),           // 지연 형식: 시간 단위
    .UPDATE_MODE      ("ASYNC")           // 업데이트 모드: 비동기 (ASYNC)
)
idelay_cm (
    .IDATAIN          (clkin_p_i),        // 입력 데이터: LVDS 클럭 P-side
    .DATAOUT          (clkin_p_d),        // 출력 데이터: 지연된 LVDS 클럭 P-side
    .CLK              (rx_clkdiv8),       // 지연 제어 클럭
    .CE               (1'b0),             // 카운터 증가 활성화 (미사용)
    .RST              (!cmt_locked),      // 리셋 신호: PLL/MMCM 락킹 신호 기반
    .INC              (1'b0),             // 카운터 증가 제어 (미사용)
    .DATAIN           (1'b0),             // 입력 데이터 대체 신호 (미사용)
    .LOAD             (Mstr_Load),        // 지연값 로드 신호
    .CNTVALUEIN       (Mstr_CntVal_In),   // 입력 카운터 값
    .EN_VTC           (!idelay_rdy),      // 지연 튜닝 활성화
    .CASC_IN          (1'b0),             // 캐스케이드 입력 (미사용)
    .CASC_RETURN      (1'b0),             // 캐스케이드 반환 (미사용)
    .CASC_OUT         (),                 // 캐스케이드 출력 (미사용)
    .CNTVALUEOUT      (Mstr_CntVal_Out)   // 출력 카운터 값
);
```



### 주요 포인트 설명

1. **DELAY_SRC ("IDATAIN")**
   - 입력 지연의 대상은 `IDATAIN`으로 설정됩니다.
   - 이 경우 `clkin_p_i` (LVDS 클럭 P-side 신호)가 지연의 대상입니다.
2. **DELAY_TYPE ("VAR_LOAD")**
   - 가변 지연 (Variable Delay) 모드로 설정됩니다.
   - 외부에서 `CNTVALUEIN` 신호를 통해 지연값을 조정할 수 있습니다.
3. **DELAY_VALUE**
   - 초기 지연값은 `DELAY_VALUE`로 설정됩니다.
   - 이 값은 파라미터로 계산되며, 기본적으로 클럭 주기(나노초)에서 `7`로 나눈 값을 사용합니다.
   - 최소값은 0, 최대값은 1250 ps입니다.
4. **REFCLK_FREQUENCY**
   - 참조 클럭의 주파수를 설정합니다. 정확한 지연 조정을 위해 사용됩니다.
   - 기본값은 300 MHz이며, 주파수 범위는 200 MHz에서 800 MHz입니다.
5. **LOAD와 CNTVALUEIN**
   - `Mstr_Load`: 지연값을 업데이트하는 신호입니다. `1`로 설정되면 새로운 지연값이 로드됩니다.
   - `Mstr_CntVal_In`: 로드될 지연값입니다.
6. **CNTVALUEOUT**
   - 현재 지연값을 출력합니다. 이 값은 `rx_state` 상태 기계에서 읽혀 비트 타이밍 및 정렬을 계산하는 데 사용됩니다.
7. **RST (Reset)**
   - PLL 또는 MMCM이 락킹 상태를 잃으면 리셋됩니다. 이는 신호 안정성을 보장하기 위한 동작입니다.

`REFCLK_FREQUENCY` 값을 **300MHz**로 설정한 이유는 **IDELAYE3 모듈의 동작 정확성과 지연 조정 해상도를 보장**하기 위해, 적절한 참조 클럭 주파수를 선택한 것입니다.





## Alexander Bang Bang Phase Detector

Alexander Bang Bang Phase Detector는 **수신 신호의 클럭과 데이터의 위상을 정렬**하는 데 사용되는 디지털 위상 감지 기법입니다. 이 기법은 신호 샘플링 시점의 위상이 적절한지 평가하고, 필요한 경우 위상을 조정하기 위해 사용됩니다. 특히 FPGA 설계에서 LVDS 인터페이스와 같은 고속 데이터 통신 시스템에서 데이터 및 클럭의 동기화를 맞추기 위해 사용됩니다.

### 기본 동작 원리

Alexander Bang Bang Phase Detector는 입력된 신호(주로 클럭)와 기준 신호(주로 데이터)의 **상승 에지와 하강 에지**를 비교하여 위상이 맞는지 확인합니다. 이를 통해 다음과 같은 결정을 내립니다:

- **위상이 앞서 있는 경우**: 클럭 샘플링 시점이 너무 빨라 신호를 놓칠 수 있으므로 **위상을 뒤로 조정**합니다.
- **위상이 뒤서 있는 경우**: 클럭 샘플링 시점이 너무 늦어 신호 왜곡이 발생할 수 있으므로 **위상을 앞으로 조정**합니다.

Bang Bang 구조는 간단하게 "증가(Increase)" 또는 "감소(Decrease)" 신호를 출력하여 위상 변경 신호를 생성합니다.



### 위상 비교 방식

Alexander Bang Bang Phase Detector는 **마스터 데이터(Master Data)**와 **슬레이브 데이터(Slave Data)**를 비교합니다. 위상 검출 로직은 아래와 같은 조건에 따라 위상을 조정합니다.

#### (1) 위상 증가 조건 (PhaseDet_Inc)

- 슬레이브 데이터의 샘플링 타이밍이 **마스터 데이터보다 뒤에 위치**할 때, 슬레이브 데이터를 앞당기기 위해 위상을 증가시킵니다.

  예: 마스터 데이터가 상승하고 슬레이브 데이터가 뒤따를 경우: 슬레이브 데이터를 앞당기도록 `PhaseDet_Inc` 신호를 활성화.

#### (2) 위상 감소 조건 (PhaseDet_Dec)

- 슬레이브 데이터의 샘플링 타이밍이 **마스터 데이터보다 앞에 위치**할 때, 슬레이브 데이터를 뒤로 늦추기 위해 위상을 감소시킵니다.

  예: 마스터 데이터가 상승했는데 슬레이브 데이터가 이미 지나갔다면: 슬레이브 데이터를 늦추도록 `PhaseDet_Dec` 신호를 활성화.

```verilog

assign PhaseDet_Inc =
        ( Slve_Less & ((~Mstr_Data[0] &  Slve_Data[0] & Mstr_Data[1]) |
                       (~Mstr_Data[1] &  Slve_Data[1] & Mstr_Data[2]) |
                       (~Mstr_Data[2] &  Slve_Data[2] & Mstr_Data[3]) |
                       (~Mstr_Data[3] &  Slve_Data[3] & Mstr_Data[4]) |
                       (~Mstr_Data[4] &  Slve_Data[4] & Mstr_Data[5]) |
                       (~Mstr_Data[5] &  Slve_Data[5] & Mstr_Data[6]) |
                       (~Mstr_Data[6] &  Slve_Data[6] & Mstr_Data[7]))) |
        (~Slve_Less & ((~Mstr_Data[0] &  Slve_Data[1] & Mstr_Data[1]) |
                       (~Mstr_Data[1] &  Slve_Data[2] & Mstr_Data[2]) |
                       (~Mstr_Data[2] &  Slve_Data[3] & Mstr_Data[3]) |
                       (~Mstr_Data[3] &  Slve_Data[4] & Mstr_Data[4]) |
                       (~Mstr_Data[4] &  Slve_Data[5] & Mstr_Data[5]) |
                       (~Mstr_Data[5] &  Slve_Data[6] & Mstr_Data[6]) |
                       (~Mstr_Data[6] &  Slve_Data[7] & Mstr_Data[7])));

assign PhaseDet_Dec =
        ( Slve_Less & ((~Mstr_Data[0] & ~Slve_Data[0] & Mstr_Data[1]) |
                       (~Mstr_Data[1] & ~Slve_Data[1] & Mstr_Data[2]) |
                       (~Mstr_Data[2] & ~Slve_Data[2] & Mstr_Data[3]) |
                       (~Mstr_Data[3] & ~Slve_Data[3] & Mstr_Data[4]) |
                       (~Mstr_Data[4] & ~Slve_Data[4] & Mstr_Data[5]) |
                       (~Mstr_Data[5] & ~Slve_Data[5] & Mstr_Data[6]) |
                       (~Mstr_Data[6] & ~Slve_Data[6] & Mstr_Data[7]))) |
        (~Slve_Less & ((~Mstr_Data[0] & ~Slve_Data[1] & Mstr_Data[1]) |
                       (~Mstr_Data[1] & ~Slve_Data[2] & Mstr_Data[2]) |
                       (~Mstr_Data[2] & ~Slve_Data[3] & Mstr_Data[3]) |
                       (~Mstr_Data[3] & ~Slve_Data[4] & Mstr_Data[4]) |
                       (~Mstr_Data[4] & ~Slve_Data[5] & Mstr_Data[5]) |
                       (~Mstr_Data[5] & ~Slve_Data[6] & Mstr_Data[6]) |
                       (~Mstr_Data[6] & ~Slve_Data[7] & Mstr_Data[7])));
```

`Slve_Less`: 슬레이브 샘플링 지연값이 마스터보다 작을 때 (`슬레이브가 마스터보다 빠른 경우`).

`~Mstr_Data[n] & Slve_Data[n] & Mstr_Data[n+1]`: 슬레이브 데이터의 상승 에지가 마스터 데이터의 상승 에지보다 느릴 때.



**`PhaseDet_Inc` 활성화** : 슬레이브가 마스터를 따라가기 위해 **슬레이브의 지연값을 줄임**.

**`PhaseDet_Dec` 활성화** : 슬레이브가 마스터보다 앞서지 않도록 **슬레이브의 지연값을 증가**.



### 동작 상태 관리

위상 검출 결과는 **`pd_count` 레지스터**에 누적되며, **위상 오버플로우(up/down)** 여부를 판단합니다.

```verilog
always @ (posedge rx_clkdiv8) begin
    if (rx_reset == 1'b1) begin
        pd_count          <= 5'd16; // 초기값
        pd_ovflw_down     <= 1'b0;  // 오버플로우(감소) 비활성화
        pd_ovflw_up       <= 1'b0;  // 오버플로우(증가) 비활성화
    end else begin
        if (rx_state != 5'h09) begin
            pd_count      <= 5'd16; // 위상 조정하지 않는 상태로 초기화
        end else begin
            pd_count <= pd_count + PhaseDet_Inc - PhaseDet_Dec;
            if (pd_count >= 5'd24) begin
                pd_ovflw_up <= 1'b1; // 위상이 너무 느린 경우
            end else if (pd_count <= 5'd8) begin
                pd_ovflw_down <= 1'b1; // 위상이 너무 빠른 경우
            end
        end
    end
end
```

##### **(1) `pd_count`**

- 위상 비교 결과를 누적하여 위상이 앞서거나 뒤서는 정도를 결정.
- `PhaseDet_Inc`: 위상 증가 신호.
- `PhaseDet_Dec`: 위상 감소 신호.

##### **(2) 오버플로우 처리**

- `pd_ovflw_up`: 위상이 너무 느린 경우 (`pd_count`가 임계값 `24` 이상).
- `pd_ovflw_down`: 위상이 너무 빠른 경우 (`pd_count`가 임계값 `8` 이하).