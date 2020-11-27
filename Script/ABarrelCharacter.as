import ADeathCamera;
import ABGamMode;

class ABarrelCharacter : ACharacter {

    default bReplicates = true;

    UPROPERTY(DefaultComponent)
    USpringArmComponent CameraSpring;
    default CameraSpring.bUsePawnControlRotation = true;
    default CameraSpring.bInheritRoll = false;

    UPROPERTY(DefaultComponent, Attach = CameraSpring )
    UCameraComponent PlayerCamera;

    UPROPERTY(DefaultComponent)
    UStaticMeshComponent PlayerBody;

    UPROPERTY(DefaultComponent)
    UInputComponent InputComponent;

    UPROPERTY(DefaultComponent, Attach = PlayerBody)
    UParticleSystemComponent ParticleSystem;
    default ParticleSystem.AutoActivate = false;
    default ParticleSystem.bReplicates = true;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        InputComponent.BindAxis(n"MoveForward", FInputAxisHandlerDynamicSignature(this, n"OnMoveForwardAxisChanged"));
        InputComponent.BindAxis(n"MoveRight", FInputAxisHandlerDynamicSignature(this, n"OnMoveRightAxisChanged"));

        InputComponent.BindAxis(n"Turn", FInputAxisHandlerDynamicSignature(this, n"OnTurn"));
        InputComponent.BindAxis(n"LookUp", FInputAxisHandlerDynamicSignature(this, n"OnLookUp"));

        InputComponent.BindAction(n"Fire", EInputEvent::IE_Pressed, FInputActionHandlerDynamicSignature(this, n"OnFire"));

    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {

    }

    UFUNCTION()
    void OnMoveForwardAxisChanged(float AxisValue)
    {
        AddMovementInput(ControlRotation.ForwardVector, AxisValue);
    }

    UFUNCTION()
    void OnMoveRightAxisChanged(float AxisValue)
    {
        AddMovementInput(ControlRotation.RightVector, AxisValue);
    }

    UFUNCTION()
    void OnTurn(float AxisValue)
    {
        AddControllerYawInput(AxisValue);
    }

    UFUNCTION()
    void OnLookUp(float AxisValue)
    {
        AddControllerPitchInput(AxisValue);
    }

    UFUNCTION()
    void OnFire(FKey key)
    {
        if(HasAuthority()){
            Death();
        }else{
            Death_Server();
        }

         Respawn(Gameplay::GetPlayerController(0));
    }

    UFUNCTION(NetMulticast)
    void Death(){
        ParticleSystem.Activate();

        PlayerBody.SimulatePhysics = true;
        PlayerBody.SetMassOverrideInKg(MassInKg = 1.f);
        PlayerBody.AddImpulseAtLocation(PlayerBody.UpVector * 3000.f, GetActorLocation());

        Gameplay::GetPlayerController(0).UnPossess();

    }

    UFUNCTION(Server)
    void Respawn(APlayerController playerController){
        Print("Called",1.f);

        auto gm = Cast<ABGameMode>(Gameplay::GetGameMode());
        if(gm != nullptr)
            gm.RespawnAsDeathCamera(playerController,GetActorLocation());
    }

    UFUNCTION(Server)
    void Death_Server(){
        Death();

    
    }
}