 // find out which sprite has been hit or clicked
 
#include "template.h"

using namespace AGK;

app App;

int sprite = 0;

void app::Begin(void)
{
  // set a virtual resolution
  agk::SetVirtualResolution ( 320, 480 );

  // display a background
  agk::CreateSprite ( 1, agk::LoadImage ( "/media/background4.jpg" ) );
  agk::SetSpriteColorAlpha ( 1, 200 );

  // load two images
  agk::LoadImage ( 1, "/media/chip5.png" );
  agk::LoadImage ( 2, "/media/chip25.png" );

  // create sprites using image
  agk::CreateSprite ( 2, 1 );
  agk::CreateSprite ( 3, 2 );

  // set their positions
  agk::SetSpritePosition ( 2, 80, 150 );
  agk::SetSpritePosition ( 3, 200, 150 );
}

int app::Loop (void)
{
  // instructions
  agk::Print ( "Click on a sprite" );
  agk::Print ( "" );
  
  agk::Print(sprite);
  
  // find out which sprite gets hit
  if ( agk::GetPointerPressed() == 1 )
  {
    sprite = agk::GetSpriteHit ( agk::GetPointerX ( ), agk::GetPointerY ( ) );
  }

  // update the screen
  agk::Sync();
    
  return 0; // return 1 to close app
}

void app::End (void)
{

}

