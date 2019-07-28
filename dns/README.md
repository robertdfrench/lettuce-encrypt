# DNS
This module reserves a static IP for your appliance by using [AWS Elastic IP][1]
and then assigns that IP to a DNS record using [AWS Route 53][2]. Reserving a
static IP allows us to restart the appliance as needed without having to update
DNS each time.

```
    ┌────────────────────────────────────────────────────┐       
    │                    EC2 Instance                    │       
    │    ┌─────────────────────────────────────────┐     │       
    │    │                  nginx                  │     │──┐    
    │    └─────────────────────────────────────────┘     │  │    
    │                         │                          │  │    
    └─────────────────────────┼──────────────────────────┘  │    
                              │                             │    
                           Serves                           │    
                         Traffic as                         │    
                              │                             │    
                              │                             │    
                              │                             │    
                              │                             │    
                              ▼                             │    
                  ┌──────────────────────┐                  │    
                  │ lettuce.example.org  │                  │    
            ┌─────│     ("A" Record)     │──┐               │    
            │     └──────────────────────┘  │               │    
            │                               │           Binds to 
            │                               │               │    
          Is a                              │               │    
       Member of                        Resolves            │    
            │                              to               │    
            │                               │               │    
            │                               ▼               │    
            │                     ┌───────────────────┐     │    
            │                     │Elastic IP Address │◀────┘    
            │                     └───────────────────┘          
            │                                                    
            ▼                                                    
  ┌──────────────────┐                                           
  │   example.org    │                                           
  │      (Zone)      │                                           
  └──────────────────┘                                           
```

By tagging the Elastic IP with the Name "lettuce", we make it discoverable by
the [parent module](../) as a terraform data object. In practice, this is a more
forgiving interface than working with terraform output / tfvars files.

[1]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/elastic-ip-addresses-eip.html
[2]: https://aws.amazon.com/route53/
