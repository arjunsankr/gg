module adder_4bit_tb;
  //inputs declaration
  logic [3:0]a;
  logic [3:0]b;
  logic cin;
   //output declaration
  logic [3:0]sum;
  logic cout;

  //instantiation
  adder_4bit(.a(a),.b(b),.sum(sum),.cin(cin),.cout(cout));

  //stimulus
  initial begin
  
    $monitor("Time=%0t | A=%d B=%d Cin=%b | Sum=%d Cout=%b | Expected=%d", 
             $time, a, b, cin, sum, cout, expected_result);


    a = 0; b = 0; cin = 0;
    #10 check_result();


    a = 3; b = 2; cin = 0; // 3 + 2 = 5
    #10 check_result();

 
    a = 5; b = 5; cin = 1; // 5 + 5 + 1 = 11
    #10 check_result();


    a = 4'd15; b = 4'd1; cin = 0;
    #10 check_result();

 
    a = 4'd15; b = 4'd15; cin = 1; // 15 + 15 + 1 = 3
    #10 check_result();
  end
  end
