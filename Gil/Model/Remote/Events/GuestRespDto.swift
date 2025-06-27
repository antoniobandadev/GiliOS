//
//  GuestDto.swift
//  Gil
//
//  Created by Antonio Banda  on 26/06/25.
//

struct GuestRespDto : Codable {
    
    let guestId: String?
    let guestsResponse: String?
    
    init(guestId: String?, guestsResponse: String?){
        
        self.guestId = guestId
        self.guestsResponse = guestsResponse
    
    }
    
}
