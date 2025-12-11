import { NextRequest, NextResponse } from 'next/server';
import { createClient } from '@supabase/supabase-js';
import { Resend } from 'resend';
// Force dynamic rendering to avoid build-time errors
export const dynamic = 'force-dynamic';


const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

export async function POST(request: NextRequest) {
  try {
    const { to, agentName, brokerageName, invitationMessage, invitationLink } = await request.json();

    const emailHtml = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <style>
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 40px 20px; text-align: center; border-radius: 10px 10px 0 0; }
            .content { background: white; padding: 40px; border: 1px solid #e0e0e0; border-top: none; border-radius: 0 0 10px 10px; }
            .button { display: inline-block; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white !important; padding: 16px 32px; text-decoration: none; border-radius: 8px; font-weight: 600; margin: 20px 0; }
            .footer { text-align: center; color: #666; font-size: 12px; margin-top: 20px; }
            .message-box { background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #667eea; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1 style="margin: 0; font-size: 32px;">HOMEY</h1>
              <p style="margin: 10px 0 0 0; opacity: 0.9;">Real Estate Connection</p>
            </div>
            <div class="content">
              <h2 style="color: #333; margin-top: 0;">You've been invited by ${agentName}</h2>
              ${brokerageName ? `<p style="color: #667eea; font-weight: 600; font-size: 16px;">${brokerageName}</p>` : ''}

              ${invitationMessage ? `
                <div class="message-box">
                  <p style="margin: 0; color: #555; font-style: italic;">"${invitationMessage}"</p>
                </div>
              ` : ''}

              <p style="color: #555;">Accept this invitation to connect with ${agentName} and start your home search journey on HOMEY.</p>

              <div style="text-align: center; margin: 30px 0;">
                <a href="${invitationLink}" class="button">Accept Invitation</a>
              </div>

              <p style="color: #999; font-size: 14px; margin-top: 30px; border-top: 1px solid #eee; padding-top: 20px;">
                This link will expire in 7 days. If you didn't expect this invitation, you can safely ignore this email.
              </p>
            </div>
            <div class="footer">
              <p>© ${new Date().getFullYear()} HOMEY. All rights reserved.</p>
            </div>
          </div>
        </body>
      </html>
    `;

    // Check which email service to use
    const resendApiKey = process.env.RESEND_API_KEY;
    const sendgridApiKey = process.env.SENDGRID_API_KEY;
    const useSupabase = process.env.USE_SUPABASE_EMAILS === 'true';

    if (resendApiKey) {
      // Option 1: Use Resend SDK
      const resend = new Resend(resendApiKey);

      const { data, error } = await resend.emails.send({
        from: process.env.EMAIL_FROM || 'HOMEY <onboarding@resend.dev>',
        to: [to],
        subject: `${agentName} invited you to connect on HOMEY`,
        html: emailHtml,
      });

      if (error) {
        console.error('Resend API error:', error);

        // Check if it's a domain verification error
        if (error.message?.includes('verify a domain') || error.statusCode === 403) {
          throw new Error(
            `Resend requires domain verification. For testing, only send to ${process.env.RESEND_TEST_EMAIL || 'your verified email'}. Or verify your domain at resend.com/domains`
          );
        }

        throw new Error(`Failed to send email via Resend: ${error.message || 'Unknown error'}`);
      }

      return NextResponse.json({ success: true, emailId: data?.id, provider: 'resend' });
    }

    else if (sendgridApiKey) {
      // Option 2: Use SendGrid
      const response = await fetch('https://api.sendgrid.com/v3/mail/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${sendgridApiKey}`,
        },
        body: JSON.stringify({
          personalizations: [{ to: [{ email: to }] }],
          from: {
            email: process.env.EMAIL_FROM?.match(/<(.+)>/)?.[1] || 'noreply@homeypocket.ai',
            name: 'HOMEY'
          },
          subject: `${agentName} invited you to connect on HOMEY`,
          content: [{ type: 'text/html', value: emailHtml }],
        }),
      });

      if (!response.ok) {
        const error = await response.text();
        console.error('SendGrid API error:', error);
        throw new Error('Failed to send email via SendGrid');
      }

      return NextResponse.json({ success: true, provider: 'sendgrid' });
    }

    else if (useSupabase && supabaseServiceKey) {
      // Option 3: Use Supabase Admin API to send email
      const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

      // Create a custom email template in Supabase or use their SMTP
      // Note: This requires additional Supabase setup
      // For now, we'll use a workaround with Supabase's built-in email

      // You can use Supabase Edge Functions for this
      // Or use their SMTP settings directly

      console.log('Supabase email sending not yet configured. Use Resend or SendGrid for now.');
      throw new Error('Supabase email not configured');
    }

    else {
      // No email service configured - log to console (development mode)
      console.log('\n' + '='.repeat(80));
      console.log('📧 INVITATION EMAIL (No email service configured)');
      console.log('='.repeat(80));
      console.log('To:', to);
      console.log('From:', agentName, brokerageName ? `(${brokerageName})` : '');
      console.log('Message:', invitationMessage || 'None');
      console.log('\n🔗 INVITATION LINK:');
      console.log(invitationLink);
      console.log('='.repeat(80) + '\n');

      return NextResponse.json({
        success: true,
        message: 'Email service not configured. Invitation link logged to console.',
        invitationLink,
        provider: 'console'
      });
    }
  } catch (error: any) {
    console.error('Error sending invitation email:', error);
    return NextResponse.json(
      { error: 'Failed to send invitation email', details: error.message },
      { status: 500 }
    );
  }
}
