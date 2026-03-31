# What you'll find in this Repo
- Helper scripts:
	- Used to generate filter coefficients, format in a manner that they can be added into our HDL code, and a way to generate sample input data for our tests.
- Four Filter Designs
	- Pipelined FIR
	- Two Parallel FIR
	- Three Parallel FIR
	- Three Parallel Pipelined FIR
- Behavioral Simulation Results
- Timing Reports
- Power and Design Resource Usage
- Filter Designs were created using the following slides as a reference
	- https://people.ece.umn.edu/users/parhi/SLIDES/chap9.pdf

# Filter Designer - MATLAB
- As stated in the project description, the goal of this project is to first implement a 100-tap Low-Pass Filter (LPF) in matlab with the transition region of $0.2\pi - 0..23 \space (\frac{rad}{sample})$.
	- Therefore, I utilized filterDesigner available in MATLAB to construct the reference version of the filter
- ![](Images/Pasted%20image%20260330183118.png)

- ![](Images/Pasted%20image%20260330183935.png)
- This filter has a sampling frequency of 47 kHz which can be configured within this designer tool.
- In the given plots, we can clearly see that significant loss occurs after $5\space kHz$. 
- Therefore, we will be looking for similar attenuation of frequencies after $5\space kHz$ in our hardware implementations.

# Pipelined FIR Filter

#### Design

- The first design that was explored was a Pipelined Filter Implementation. We can start with a simple reference design as we've seen throughout class and simply add pipeline registers.
	- The pipeline registers are denoted by dotted blue lines perpendicular to the data paths.
- Using the Vivado schematic Viewer, we can see what the Synthesis tool maps the HDL code too.
- What becomes clear is that the Vivado schematic matches our intended design.
![](Images/Pasted%20image%20260330182623.png)

![](Images/Pasted%20image%20260324171139.png)


#### Behavioral Simulation
- Using the Vivado simulator and a simple testbench written in SystemVerilog, I found that the hardware implementation matches the expected behavior from the Magnitude response that we saw in the MATLAB tool. 

![](Images/Pasted%20image%20260324170445.png)


#### Timing Analysis
- I performed timing analysis after running implementation in Vivado.
- Vivado allows us to see how the design is routed on the actual chip.

![](Images/Pasted%20image%20260324172508.png)

- Additionally, we can use the TCL console to perform timing analysis.
- This report allows us to see the where most of the design delay comes from as well as other key FPGA design considerations such as slack.

```
Timing Report

Slack (MET) :             21170.541ns  (required time - arrival time)
  Source:                 acc_pipe_reg[101][63]/C
                            (rising edge-triggered cell FDRE clocked by clk  {rise@0.000ns fall@10638.000ns period=21276.000ns})
  Destination:            dout[32]
                            (output port clocked by clk  {rise@0.000ns fall@10638.000ns period=21276.000ns})
  Path Group:             clk
  Path Type:              Max at Slow Process Corner
  Requirement:            21276.000ns  (clk rise@21276.000ns - clk rise@0.000ns)
  Data Path Delay:        2.006ns  (logic 0.985ns (49.111%)  route 1.021ns (50.889%))
  Logic Levels:           1  (OBUF=1)
  Output Delay:           100.000ns
  Clock Path Skew:        -3.417ns (DCD - SCD + CPR)
    Destination Clock Delay (DCD):    0.000ns = ( 21276.000 - 21276.000 ) 
    Source Clock Delay      (SCD):    3.417ns
    Clock Pessimism Removal (CPR):    0.000ns
  Clock Uncertainty:      0.035ns  ((TSJ^2 + TIJ^2)^1/2 + DJ) / 2 + PE
    Total System Jitter     (TSJ):    0.071ns
    Total Input Jitter      (TIJ):    0.000ns
    Discrete Jitter          (DJ):    0.000ns
    Phase Error              (PE):    0.000ns

    Location             Delay type                Incr(ns)  Path(ns)    Netlist Resource(s)
  -------------------------------------------------------------------    -------------------
                         (clock clk rise edge)        0.000     0.000 r  
                         propagated clock network latency
                                                      3.417     3.417    
                         FDRE                         0.000     3.417 r  acc_pipe_reg[101][63]/C
                         FDRE (Prop_FDRE_C_Q)         0.079     3.496 r  acc_pipe_reg[101][63]/Q
                         net (fo=32, unplaced)        1.021     4.517    dout_OBUF[32]
                         OBUF (Prop_OBUF_I_O)         0.906     5.424 r  dout_OBUF[32]_inst/O
                         net (fo=0)                   0.000     5.424    dout[32]
                                                                      r  dout[32] (OUT)
  -------------------------------------------------------------------    -------------------

                         (clock clk rise edge)    21276.000 21276.000 r  
                         propagated clock network latency
                                                      0.000 21276.000    
                         clock pessimism              0.000 21276.000    
                         clock uncertainty           -0.035 21275.965    
                         output delay              -100.000 21175.965    
  -------------------------------------------------------------------
                         required time                      21175.965    
                         arrival time                          -5.424    
  -------------------------------------------------------------------
                         slack                              21170.541    
```


### Power and Resource Utilization
- Shown below are key power and resource data points for this design.
- NOTE: This will appear in all the resources analysis so its worthwhile to address here: I/O usage is very high.
	- This is because I have not used anything like a high level wrapper module

![](Images/Pasted%20image%20260324172853.png)

![](Images/Pasted%20image%20260324173208.png)


# Two Parallel FIR Filter

## Design
- Parallel Filters use Polyphase Decomposition and this design contains NO pipelining
- ![](Images/Pasted%20image%20260330182648.png)


## Simulation
- Once again, the simulation output matches the expected response.
- ![](Images/Pasted%20image%20260330151221.png)

## Timing Analysis
- Chip Layout
- ![](Images/Pasted%20image%20260330152830.png)
```
  Timing Report

Slack (MET) :             21152.850ns  (required time - arrival time)
  Source:                 buffer2_reg[19][11]/C
                            (rising edge-triggered cell FDCE clocked by clk  {rise@0.000ns fall@10638.000ns period=21276.000ns})
  Destination:            dout2[62]
                            (output port clocked by clk  {rise@0.000ns fall@10638.000ns period=21276.000ns})
  Path Group:             clk
  Path Type:              Max at Slow Process Corner
  Requirement:            21276.000ns  (clk rise@21276.000ns - clk rise@0.000ns)
  Data Path Delay:        20.274ns  (logic 5.720ns (28.212%)  route 14.555ns (71.788%))
  Logic Levels:           35  (CARRY8=14 DSP_A_B_DATA=1 DSP_ALU=1 DSP_M_DATA=1 DSP_MULTIPLIER=1 DSP_OUTPUT=1 DSP_PREADD_DATA=1 LUT3=8 LUT4=6 OBUF=1)
  Output Delay:           100.000ns
  Clock Path Skew:        -2.841ns (DCD - SCD + CPR)
    Destination Clock Delay (DCD):    0.000ns = ( 21276.000 - 21276.000 ) 
    Source Clock Delay      (SCD):    2.841ns
    Clock Pessimism Removal (CPR):    0.000ns
  Clock Uncertainty:      0.035ns  ((TSJ^2 + TIJ^2)^1/2 + DJ) / 2 + PE
    Total System Jitter     (TSJ):    0.071ns
    Total Input Jitter      (TIJ):    0.000ns
    Discrete Jitter          (DJ):    0.000ns
    Phase Error              (PE):    0.000ns

    Location             Delay type                Incr(ns)  Path(ns)    Netlist Resource(s)
  -------------------------------------------------------------------    -------------------

  -------------------------------------------------------------------    -------------------

                         (clock clk rise edge)    21276.000 21276.000 r  
                         propagated clock network latency
                                                      0.000 21276.000    
                         clock pessimism              0.000 21276.000    
                         clock uncertainty           -0.035 21275.965    
                         output delay              -100.000 21175.965    
  -------------------------------------------------------------------
                         required time                      21175.965    
                         arrival time                         -23.115    
  -------------------------------------------------------------------
                         slack                              21152.850    

```

## Power and Resource Utilization
- ![](Images/Pasted%20image%20260330153448.png)

- Something notable is that we see an increase in DSP slice usage. 
	- Very much expected.
# Three Parallel FIR Filter

## Design
- Fast Three Parallel FIR Filter Design
- ![](Images/Pasted%20image%20260330182703.png)


## Simulation
- ![](Images/Pasted%20image%20260330154326.png)
- The simulation output demonstrates that the hardware implementation matches the expected response of the MATLAB filter. 

## Timing Analysis
report_timing -max_paths 1 -path_type full -delay_type max
- ![](Images/Pasted%20image%20260330162652.png)



```
 Timing Report

Slack (MET) :             21146.637ns  (required time - arrival time)
  Source:                 buffer1_reg[28][3]/C
                            (rising edge-triggered cell FDCE clocked by clk  {rise@0.000ns fall@10638.000ns period=21276.000ns})
  Destination:            dout3[53]
                            (output port clocked by clk  {rise@0.000ns fall@10638.000ns period=21276.000ns})
  Path Group:             clk
  Path Type:              Max at Slow Process Corner
  Requirement:            21276.000ns  (clk rise@21276.000ns - clk rise@0.000ns)
  Data Path Delay:        26.527ns  (logic 6.581ns (24.811%)  route 19.945ns (75.189%))
  Logic Levels:           41  (CARRY8=16 DSP_A_B_DATA=1 DSP_ALU=1 DSP_M_DATA=1 DSP_MULTIPLIER=1 DSP_OUTPUT=1 DSP_PREADD_DATA=1 LUT3=9 LUT4=5 LUT5=2 LUT6=2 OBUF=1)
  Output Delay:           100.000ns
  Clock Path Skew:        -2.803ns (DCD - SCD + CPR)
    Destination Clock Delay (DCD):    0.000ns = ( 21276.000 - 21276.000 ) 
    Source Clock Delay      (SCD):    2.803ns
    Clock Pessimism Removal (CPR):    0.000ns
  Clock Uncertainty:      0.035ns  ((TSJ^2 + TIJ^2)^1/2 + DJ) / 2 + PE
    Total System Jitter     (TSJ):    0.071ns
    Total Input Jitter      (TIJ):    0.000ns
    Discrete Jitter          (DJ):    0.000ns
    Phase Error              (PE):    0.000ns

    Location             Delay type                Incr(ns)  Path(ns)    Netlist Resource(s)
  -------------------------------------------------------------------    -------------------
  -------------------------------------------------------------------    -------------------

                         (clock clk rise edge)    21276.000 21276.000 r  
                         propagated clock network latency
                                                      0.000 21276.000    
                         clock pessimism              0.000 21276.000    
                         clock uncertainty           -0.035 21275.965    
                         output delay              -100.000 21175.965    
  -------------------------------------------------------------------
                         required time                      21175.965    
                         arrival time                         -29.330    
  -------------------------------------------------------------------
                         slack                              21146.637   
```
  
## Power and Resource Utilization
- ![](Images/Pasted%20image%20260330162836.png)
- ![](Images/Pasted%20image%20260330162925.png)

# Three Parallel Pipelined FIR Filter
## Design
- Note: For this implementation, I found it made sense to duplicate the earlier Pipelined FIR Filter Implementation 3 times in a toplevel file.
## Simulation
- ![](Images/Pasted%20image%20260330163635.png)

## Timing
```
report_timing -max_paths 1 -path_type full -delay_type max
```

- ![](Images/Pasted%20image%20260330165347.png)
- What results from the duplication is a significantly higher chip area usage.
```
  Timing Report

Slack (MET) :             21169.904ns  (required time - arrival time)
  Source:                 F2/acc_pipe_reg[101][53]/C
                            (rising edge-triggered cell FDRE clocked by clk  {rise@0.000ns fall@10638.000ns period=21276.000ns})
  Destination:            dout2[22]
                            (output port clocked by clk  {rise@0.000ns fall@10638.000ns period=21276.000ns})
  Path Group:             clk
  Path Type:              Max at Slow Process Corner
  Requirement:            21276.000ns  (clk rise@21276.000ns - clk rise@0.000ns)
  Data Path Delay:        3.092ns  (logic 1.081ns (34.953%)  route 2.011ns (65.047%))
  Logic Levels:           1  (OBUF=1)
  Output Delay:           100.000ns
  Clock Path Skew:        -2.969ns (DCD - SCD + CPR)
    Destination Clock Delay (DCD):    0.000ns = ( 21276.000 - 21276.000 ) 
    Source Clock Delay      (SCD):    2.969ns
    Clock Pessimism Removal (CPR):    0.000ns
  Clock Uncertainty:      0.035ns  ((TSJ^2 + TIJ^2)^1/2 + DJ) / 2 + PE
    Total System Jitter     (TSJ):    0.071ns
    Total Input Jitter      (TIJ):    0.000ns
    Discrete Jitter          (DJ):    0.000ns
    Phase Error              (PE):    0.000ns

    Location             Delay type                Incr(ns)  Path(ns)    Netlist Resource(s)
  -------------------------------------------------------------------    -------------------
  -------------------------------------------------------------------    -------------------

                         (clock clk rise edge)    21276.000 21276.000 r  
                         propagated clock network latency
                                                      0.000 21276.000    
                         clock pessimism              0.000 21276.000    
                         clock uncertainty           -0.035 21275.965    
                         output delay              -100.000 21175.965    
  -------------------------------------------------------------------
                         required time                      21175.965    
                         arrival time                          -6.060    
  -------------------------------------------------------------------
                         slack                              21169.904  
```


## Utilization and Power
- ![](Images/Pasted%20image%20260330165624.png)

# Results and Discussion

|       Filter Type        | Slack (ns) | Logic Delay (ns) | LUT Cells | FF Cells | DSP Cells | IO Cells | Total Cells | Dynamic Power (W) | Static Power (W) |
| :----------------------: | :--------: | :--------------: | :-------: | :------: | :-------: | :------: | :---------: | :---------------: | :--------------: |
|        Pipelined         | 21170.736  |      2.529       |   6380    |   9418   |    102    |    82    |    15982    |       0.019       |      2.945       |
|       Two-Parallel       | 21152.850  |      5.761       |   5378    |   1696   |    153    |   162    |    7390     |       0.037       |      2.945       |
|      Three-Parallel      | 21146.637  |      6.627       |   10484   |   1760   |    525    |   242    |    13011    |       0.056       |      2.945       |
| Three-Parallel Pipelined | 21169.904  |      2.500       |   19140   |  28254   |    306    |   242    |    47942    |       0.056       |      2.945       |

### Why pipelining?
- Using the results found from the analysis, we see a clear benefit in pipelining specifically when looking at the Three Parallel and Three Parallel Pipelined Implementations. The main thing I noticed  was that the Three Parallel implementation sees ~$2.5$ time increase in Logic Delay. This is important for scaling the design. If we try to scale this design in terms of a higher clock speed, we will likely see the Three Parallel Version fail timing before the Three parallel Pipelined Version. This is because the high logic depth will lead to negative slack timing issues.
- In an application where clock speed isn't the most important, the three parallel version would be the best.
## DSP Usage
- Another result that caught my eye was the DSP usage when going from a Three Parallel Filter Design to a Three Parallel Pipelined Version. The DSP slice usage lowers significantly when implementing pipelining. This is likely due to the fact that the tool must break arithmetic across multiple DSPs to manage long combinational paths in the non-pipelined version
## Chip Area
- Finally, another notable thing I found was the increase in overall resource usage from the Pipelined FIR filter, to the Three Parallel FIR Filter. The chip visualization is great for seeing how designs scale on an actual FPGA chip. In industry applications, these are things that the designer must consider, especially since filtering may not be the only function the FPGA must fulfill meaning that routing congestion can become a significant bottleneck in some cases.

# Future Work
- Exploring the effects of different quantization methods on Power and Area
- Analyzing the tradeoffs in Filter performance against the number of taps used

