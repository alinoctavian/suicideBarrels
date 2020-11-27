import ADeathCamera;
import Enums;

event void FOnMessageDelegate(FString playerName,FString message);

class ABGameMode : AGameModeBase {

    UPROPERTY(Replicated)
    EPhase Phase;

    UPROPERTY(Replicated)
    int Round = 0;

    UPROPERTY(Replicated)
    int PlayersWaiting = 0;

    UPROPERTY(Replicated)
    FOnMessageDelegate OnMessage;

    UFUNCTION(BlueprintOverride)
    void BeginPlay(){

        if(HasAuthority()){
            Phase = EPhase::WaitingForPlayers;

        }

    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds){
        switch(Phase){
            case EPhase::WaitingForPlayers:
                WaitingForPlayers();
                break;
            case EPhase::RoundStarting:
                RoundStarting();
                break;
            case EPhase::RoundWarmup:
                RoundWarmup();
                break;
            case EPhase::RoundActive:
                RoundActive();
                break;
            case EPhase::RoundOver:
                RoundOver();
                break;
        }

    }


    UFUNCTION(Server)
    void RespawnAsDeathCamera(APlayerController playerController, FVector location){
        if(playerController != nullptr){
            if(HasAuthority()){
                auto camera = ADeathCamera::Spawn(location);

                if(camera != nullptr)
                    playerController.Possess(camera);

            }
        }
    }

    UFUNCTION()
    void SwitchPhase(EPhase phase){
        if(Phase == phase) 
            return;

        Phase = phase;
    }


    void WaitingForPlayers(){
       
    }

    UFUNCTION(NetMulticast)
    void OnPlayerMessage(FString playerName, FString message){
        OnMessage.Broadcast(playerName, message);
    }

    UFUNCTION(Server)
    void OnPlayerMessageServer(FString playerName, FString message){
        OnPlayerMessage(playerName,message);
    }

    void RoundStarting(){

    }

    void RoundWarmup(){

    }

    void RoundActive(){

    }

    void RoundOver(){

    }
}
